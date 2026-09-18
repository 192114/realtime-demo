import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:native_app/config/theme/app_colors.dart';
import 'package:native_app/config/theme/app_spacing.dart';
import 'package:native_app/shared/widgets/message/message.dart';
import 'package:permission_handler/permission_handler.dart';

import '../call_coordinator.dart';
import '../call_event_bus.dart';
import '../models/call_models.dart';
import '../models/call_route_args.dart';

/// 通话页：连接 LiveKit 房间收发媒体；对方挂断以信令事件为准，房间断开兜底
class ActiveCallPage extends StatefulWidget {
  const ActiveCallPage({super.key, required this.args});

  final CallRouteArgs args;

  @override
  State<ActiveCallPage> createState() => _ActiveCallPageState();
}

class _ActiveCallPageState extends State<ActiveCallPage> {
  Room? _room;
  EventsListener<RoomEvent>? _listener;
  StreamSubscription<Map<String, dynamic>>? _events;
  Timer? _ticker;
  bool _connecting = true;
  bool _muted = false;
  bool _ending = false;
  RemoteVideoTrack? _remoteVideoTrack;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _events = listenCallEvents(widget.args.call.callId, _onSignal);
    unawaited(_connect());
  }

  @override
  void dispose() {
    _ending = true;
    unawaited(_events?.cancel());
    _ticker?.cancel();
    unawaited(_listener?.dispose());
    // 房间可能尚未建立；断开失败不阻塞页面销毁
    unawaited(_room?.disconnect());
    unawaited(_room?.dispose());
    super.dispose();
  }

  Future<void> _connect() async {
    try {
      if (!await _requestPermissions()) {
        if (mounted) AppMessage.error('需要麦克风权限才能通话');
        await _hangup(notifyServer: false);
        return;
      }
      final room = Room();
      _room = room;
      _listener = room.createListener()
        ..on<RoomDisconnectedEvent>((_) => _onRoomClosed('连接已断开'))
        ..on<ParticipantDisconnectedEvent>((_) => _onRoomClosed('对方已挂断'))
        ..on<TrackSubscribedEvent>((event) {
          if (event.track.kind == TrackType.VIDEO && mounted) {
            setState(() => _remoteVideoTrack = event.track as RemoteVideoTrack);
          }
        });
      await room.connect(widget.args.liveKitUrl, widget.args.token);
      await room.localParticipant?.setMicrophoneEnabled(true);
      // 视频通话发布本地视频轨；摄像头不可用（如模拟器）时降级纯音频，不阻塞通话
      if (widget.args.call.isVideo) {
        try {
          await room.localParticipant?.setCameraEnabled(true);
        } catch (_) {
          if (mounted) AppMessage.error('摄像头不可用，已降级为语音通话');
        }
      }
      if (!mounted) return;
      setState(() {
        _connecting = false;
        _muted = false;
      });
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
      });
    } catch (_) {
      if (!mounted) return;
      AppMessage.error('连接通话失败，请重试');
      if (context.canPop()) context.pop();
    }
  }

  void _onSignal(CallEvent event) {
    if (_ending || !mounted) return;
    switch (event.eventType) {
      case 'call.ended':
        _onRoomClosed('通话已结束');
      case 'call.rejected':
      case 'call.cancelled':
      case 'call.timeout':
        _onRoomClosed('通话已结束');
    }
  }

  Future<bool> _requestPermissions() async {
    final permissions = [Permission.microphone];
    if (widget.args.call.isVideo) permissions.add(Permission.camera);
    final statuses = await permissions.request();
    return statuses[Permission.microphone]?.isGranted ?? false;
  }

  void _onRoomClosed(String message) {
    if (_ending || !mounted) return;
    _ending = true;
    AppMessage.info(message);
    _ticker?.cancel();
    if (context.canPop()) context.pop();
  }

  Future<void> _hangup({bool notifyServer = true}) async {
    if (_ending) return;
    _ending = true;
    _ticker?.cancel();
    if (notifyServer) {
      try {
        await callCoordinator.remote().end(widget.args.call.callId);
      } catch (_) {
        // 网络失败时房间已断开；服务端 webhook 负责对账收敛状态。
      }
    }
    if (mounted && context.canPop()) context.pop();
  }

  Future<void> _toggleMute() async {
    final room = _room;
    if (room == null) return;
    final next = !_muted;
    try {
      await room.localParticipant?.setMicrophoneEnabled(!next);
      if (mounted) setState(() => _muted = next);
    } catch (_) {
      if (mounted) AppMessage.error('静音切换失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    final call = widget.args.call;
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        // 系统返回手势按挂断处理，避免状态悬挂。
        if (!didPop) unawaited(_hangup());
      },
      child: Scaffold(
        backgroundColor: AppColors.onPrimaryContainer,
        body: SafeArea(
          child: _connecting
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    const Spacer(),
                    if (call.isVideo && _remoteVideoTrack != null)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppSpacing.lg),
                            child: VideoTrackRenderer(_remoteVideoTrack!),
                          ),
                        ),
                      )
                    else
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.primary,
                        child: Icon(call.isVideo ? Icons.videocam : Icons.call,
                            size: 40, color: AppColors.onPrimary),
                      ),
                    SizedBox(height: AppSpacing.xxl),
                    Text(call.isVideo ? call.calleeNickname ?? '对方' : _peerName(),
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(color: AppColors.onPrimaryContainer)),
                    SizedBox(height: AppSpacing.sm),
                    Text(_elapsedText,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: AppColors.secondary)),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton.filled(
                          onPressed: () => unawaited(_toggleMute()),
                          icon: Icon(_muted ? Icons.mic_off : Icons.mic),
                          iconSize: 28,
                          tooltip: _muted ? '取消静音' : '静音',
                          style: IconButton.styleFrom(
                            backgroundColor: _muted
                                ? AppColors.secondaryContainer
                                : AppColors.primaryContainer,
                            foregroundColor: _muted
                                ? AppColors.onSecondaryContainer
                                : AppColors.onPrimaryContainer,
                            minimumSize: const Size(64, 64),
                          ),
                        ),
                        IconButton.filled(
                          onPressed: () => unawaited(_hangup()),
                          icon: const Icon(Icons.call_end),
                          iconSize: 28,
                          tooltip: '挂断',
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: AppColors.onError,
                            minimumSize: const Size(64, 64),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xxl),
                  ],
                ),
        ),
      ),
    );
  }

  String _peerName() {
    final call = widget.args.call;
    final myUserId = callCoordinator.myUserId;
    if (myUserId == null) return call.callerNickname ?? '对方';
    return call.calleeId == myUserId
        ? call.callerNickname ?? '对方'
        : call.calleeNickname ?? '对方';
  }

  String get _elapsedText {
    final minutes = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${_elapsed.inHours > 0 ? '${_elapsed.inHours}:' : ''}$minutes:$seconds';
  }
}
