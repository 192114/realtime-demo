import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:native_app/config/theme/app_colors.dart';
import 'package:native_app/config/theme/app_spacing.dart';
import 'package:native_app/core/network/api_exception.dart';
import 'package:native_app/core/router/app_router.dart';
import 'package:native_app/shared/widgets/message/message.dart';
import 'package:permission_handler/permission_handler.dart';

import '../call_coordinator.dart';
import '../call_event_bus.dart';
import '../models/call_models.dart';
import '../models/call_route_args.dart';

/// 来电页：接听需先授予媒体权限，拒绝直接返回
class IncomingCallPage extends StatefulWidget {
  const IncomingCallPage({super.key, required this.call});

  final CallSession call;

  @override
  State<IncomingCallPage> createState() => _IncomingCallPageState();
}

class _IncomingCallPageState extends State<IncomingCallPage> {
  StreamSubscription<Map<String, dynamic>>? _events;
  bool _accepting = false;
  bool _rejecting = false;

  @override
  void initState() {
    super.initState();
    // 页面接管后清除全局来电信号，避免重复导航
    callCoordinator.consumeIncoming();
    _events = listenCallEvents(widget.call.callId, _onEvent);
  }

  @override
  void dispose() {
    unawaited(_events?.cancel());
    super.dispose();
  }

  void _onEvent(CallEvent event) {
    if (!mounted) return;
    switch (event.eventType) {
      case 'call.cancelled':
        _closeWithMessage('对方已取消呼叫');
      case 'call.timeout':
        _closeWithMessage('对方长时间未等到接听');
      case 'call.rejected':
        if (context.canPop()) context.pop();
      case 'call.ended':
        _closeWithMessage('通话已结束');
      case 'call.accepted':
        if (context.canPop()) context.pop();
    }
  }

  void _closeWithMessage(String message) {
    if (!mounted) return;
    AppMessage.info(message);
    if (context.canPop()) context.pop();
  }

  Future<bool> _requestPermissions() async {
    final permissions = [Permission.microphone];
    if (widget.call.isVideo) permissions.add(Permission.camera);
    final statuses = await permissions.request();
    return statuses.values.every((status) => status.isGranted);
  }

  Future<void> _accept() async {
    if (_accepting) return;
    setState(() => _accepting = true);
    try {
      if (!await _requestPermissions()) {
        setState(() => _accepting = false);
        AppMessage.error(widget.call.isVideo ? '需要麦克风和相机权限才能接听' : '需要麦克风权限才能接听');
        return;
      }
      final accepted = await callCoordinator.remote().accept(widget.call.callId);
      if (!mounted) return;
      final status = accepted.callStatus;
      final token = accepted.token;
      final url = accepted.liveKitUrl;
      if (status == CallStatus.inCall && token != null && token.isNotEmpty
          && url != null && url.isNotEmpty) {
        context.pushReplacement(RoutePaths.callActive,
            extra: CallRouteArgs(call: accepted, token: token, liveKitUrl: url));
        return;
      }
      // 接听瞬间对方已挂断：幂等响应携带终态，按其结果提示。
      _closeWithMessage(switch (status) {
        CallStatus.rejected => '对方已拒绝',
        CallStatus.cancelled => '对方已取消呼叫',
        CallStatus.timeout => '对方长时间未等到接听',
        _ => '通话已结束',
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _accepting = false);
      AppMessage.error(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _accepting = false);
      AppMessage.error('接听失败，请重试');
    }
  }

  Future<void> _reject() async {
    if (_rejecting) return;
    setState(() => _rejecting = true);
    try {
      await callCoordinator.remote().reject(widget.call.callId);
    } catch (_) {
      // 网络失败也退出页面；服务端超时调度负责收敛状态。
    }
    if (mounted && context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final call = widget.call;
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        // 系统返回手势按拒绝处理，避免状态悬挂。
        if (!didPop) unawaited(_reject());
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryContainer,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primary,
                child: Icon(call.isVideo ? Icons.videocam : Icons.call,
                    size: 40, color: AppColors.onPrimary),
              ),
              SizedBox(height: AppSpacing.xxl),
              Text(call.callerNickname ?? '对方',
                  style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.onPrimaryContainer)),
              SizedBox(height: AppSpacing.sm),
              Text(call.isVideo ? '邀请你视频通话' : '邀请你语音通话',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: AppColors.onPrimaryContainer)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CallAction(
                    label: _rejecting ? '拒绝中…' : '拒绝',
                    icon: Icons.call_end,
                    foreground: AppColors.onErrorContainer,
                    background: AppColors.errorContainer,
                    onPressed: _rejecting ? null : () => unawaited(_reject()),
                  ),
                  _CallAction(
                    label: _accepting ? '接听中…' : '接听',
                    icon: Icons.call,
                    foreground: AppColors.onPrimaryContainer,
                    background: AppColors.primary,
                    onPressed: _accepting ? null : () => unawaited(_accept()),
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
}

/// 通话操作大按钮：最小 88x56，满足触控目标要求
class _CallAction extends StatelessWidget {
  const _CallAction({required this.label, required this.icon,
    required this.foreground, required this.background, required this.onPressed});

  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filled(
          onPressed: onPressed,
          icon: Icon(icon),
          iconSize: 32,
          style: IconButton.styleFrom(
            backgroundColor: background,
            foregroundColor: foreground,
            minimumSize: const Size(88, 88),
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(label, style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: AppColors.onPrimaryContainer)),
      ],
    );
  }
}
