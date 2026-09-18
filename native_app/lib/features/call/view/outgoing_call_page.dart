import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:native_app/config/theme/app_colors.dart';
import 'package:native_app/config/theme/app_spacing.dart';
import 'package:native_app/core/network/api_exception.dart';
import 'package:native_app/core/router/app_router.dart';
import 'package:native_app/shared/widgets/message/message.dart';

import '../call_coordinator.dart';
import '../call_event_bus.dart';
import '../models/call_models.dart';
import '../models/call_route_args.dart';

/// 呼出页：等待对方接听，信令事件驱动页面流转
class OutgoingCallPage extends StatefulWidget {
  const OutgoingCallPage({super.key, required this.call});

  final CallSession call;

  @override
  State<OutgoingCallPage> createState() => _OutgoingCallPageState();
}

class _OutgoingCallPageState extends State<OutgoingCallPage> {
  StreamSubscription<Map<String, dynamic>>? _events;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
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
      case 'call.accepted':
        final accepted = callFromEvent(event);
        if (accepted == null) return;
        final token = widget.call.token;
        final url = widget.call.liveKitUrl;
        if (token == null || token.isEmpty || url == null || url.isEmpty) {
          _closeWithMessage('通话凭证缺失，请重新发起');
          return;
        }
        context.pushReplacement(RoutePaths.callActive,
            extra: CallRouteArgs(call: accepted, token: token, liveKitUrl: url));
      case 'call.rejected':
        _closeWithMessage('对方已拒绝');
      case 'call.timeout':
        _closeWithMessage('对方无应听');
      case 'call.cancelled':
        if (context.canPop()) context.pop();
      case 'call.ended':
        _closeWithMessage('通话已结束');
    }
  }

  void _closeWithMessage(String message) {
    if (!mounted) return;
    AppMessage.info(message);
    if (context.canPop()) context.pop();
  }

  Future<void> _cancel() async {
    if (_cancelling) return;
    setState(() => _cancelling = true);
    try {
      await callCoordinator.remote().cancel(widget.call.callId);
    } on ApiException {
      // 网络失败也要退出页面；服务端超时调度负责收敛状态。
    } catch (_) {
      // 同上，不向用户重复暴露错误。
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
        // 系统返回手势按取消处理，避免状态悬挂。
        if (!didPop) unawaited(_cancel());
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
              Text(call.calleeNickname ?? '对方',
                  style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.onPrimaryContainer)),
              SizedBox(height: AppSpacing.sm),
              Text(call.isVideo ? '邀请对方视频通话…' : '邀请对方语音通话…',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: AppColors.onPrimaryContainer)),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: _cancelling ? null : _cancel,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.errorContainer,
                  foregroundColor: AppColors.onErrorContainer,
                  minimumSize: const Size.fromHeight(56),
                ),
                icon: const Icon(Icons.call_end),
                label: Text(_cancelling ? '正在取消…' : '取消呼叫'),
              ),
              SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
