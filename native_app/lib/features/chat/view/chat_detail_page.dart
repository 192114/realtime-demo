import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:native_app/config/theme/app_colors.dart';
import 'package:native_app/config/theme/app_spacing.dart';
import 'package:native_app/config/theme/app_typography.dart';
import 'package:native_app/core/network/api_exception.dart';
import 'package:native_app/core/router/app_router.dart';
import 'package:native_app/features/call/call_coordinator.dart';
import 'package:native_app/shared/widgets/message/message.dart';

import '../models/chat_models.dart';
import '../repositories/chat_realtime_coordinator.dart';
import '../view_model/chat_view_models.dart';
import '../widgets/chat_offline_banner.dart';

/// 聊天详情页：消息按 seq 排列，向上滚动加载历史
class ChatDetailPage extends ConsumerStatefulWidget {
  const ChatDetailPage({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends ConsumerState<ChatDetailPage> {
  final _scrollController = ScrollController();
  final _inputController = TextEditingController();
  static const _loadMoreThreshold = 200.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    // reverse 列表：maxScrollExtent 一端是更早的历史消息
    if (position.maxScrollExtent - position.pixels <= _loadMoreThreshold) {
      ref
          .read(chatDetailViewModelProvider(widget.conversationId).notifier)
          .loadMore();
    }
  }

  bool _calling = false;

  /// 发起语音/视频通话；成功后进入呼出页等待信令事件流转
  Future<void> _startCall(ChatDetailState state, String mediaType) async {
    if (_calling) return;
    final peerUserId = state.peerUserId;
    if (peerUserId == null || peerUserId.isEmpty) {
      AppMessage.error('对方信息尚未同步，请稍后重试');
      return;
    }
    _calling = true;
    try {
      final call = await callCoordinator.remote().initiate(peerUserId, mediaType);
      if (!mounted) return;
      context.push(RoutePaths.callOutgoing, extra: call);
    } on ApiException catch (error) {
      if (mounted) AppMessage.error(error.message);
    } catch (_) {
      if (mounted) AppMessage.error('发起通话失败，请重试');
    } finally {
      _calling = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = chatDetailViewModelProvider(widget.conversationId);
    final state = ref.watch(provider);

    ref.listen<ChatDetailState>(provider, (prev, next) {
      if (next.errorSeq != prev?.errorSeq) {
        AppMessage.error(next.actionError!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(state.peerNickname ?? '聊天'),
        actions: [
          IconButton(
            onPressed: () => unawaited(_startCall(state, 'AUDIO')),
            icon: const Icon(Icons.call),
            tooltip: '语音通话',
          ),
          IconButton(
            onPressed: () => unawaited(_startCall(state, 'VIDEO')),
            icon: const Icon(Icons.videocam),
            tooltip: '视频通话',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (state.connection == ChatConnection.offline)
              ChatOfflineBanner(
                onRetry: () => ref.read(provider.notifier).retryConnection(),
              ),
            Expanded(child: _buildList(state)),
            _buildInput(state),
          ],
        ),
      ),
    );
  }

  Widget _buildList(ChatDetailState state) {
    final rows = <_Row>[
      // reverse 列表 index 0 位于视觉最底部：最新 pending 在最下
      ...state.pending.reversed.map(_Row.pending),
      ...state.messages.map(_Row.message),
    ];
    final showTailLoader = state.loadingMore && rows.isNotEmpty;
    if (rows.isEmpty && !showTailLoader) {
      return Center(
        child: Text(
          '暂无消息，发送第一条消息吧',
          style: AppTypography.bodyMedium
              .copyWith(color: AppColors.onSurfaceVariant),
        ),
      );
    }
    return ListView.builder(
      reverse: true,
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: rows.length + (showTailLoader ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == rows.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final row = rows[index];
        if (row.pending != null) {
          return _PendingBubble(
            message: row.pending!,
            sending: state.sending.contains(row.pending!.clientMsgId),
            onRetry: () => ref
                .read(chatDetailViewModelProvider(widget.conversationId).notifier)
                .retryPending(row.pending!),
          );
        }
        return _MessageBubble(message: row.message!, state: state);
      },
    );
  }

  Widget _buildInput(ChatDetailState state) {
    final enabled = state.repository != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              enabled: enabled,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: '输入消息…',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm + 2,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton.filled(
              tooltip: '发送',
              onPressed: enabled ? _send : null,
              icon: const Icon(Icons.send_outlined),
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    ref
        .read(chatDetailViewModelProvider(widget.conversationId).notifier)
        .send(text);
  }
}

/// 列表行：已确认消息或待确认消息
class _Row {
  const _Row.message(ChatMessage this.message) : pending = null;
  const _Row.pending(PendingMessage this.pending) : message = null;

  final ChatMessage? message;
  final PendingMessage? pending;
}

/// 已确认消息气泡：自己可见“已发送/已读”两态；通话记录按居中系统样式渲染
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.state});

  final ChatMessage message;
  final ChatDetailState state;

  @override
  Widget build(BuildContext context) {
    if (message.type == messageTypeCall) {
      return _CallMessageChip(message: message);
    }
    final mine = message.senderId == state.myUserId;
    final read = mine && message.seq <= state.peerReadSeq;
    final maxWidth = MediaQuery.of(context).size.width * 0.72;
    final bubble = Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: mine ? AppColors.primary : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message.text,
        style: AppTypography.bodyMedium.copyWith(
          color: mine ? AppColors.onPrimary : AppColors.onSurface,
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Align(
        alignment:
            mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            bubble,
            if (mine)
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.xs,
                  right: AppSpacing.xs,
                ),
                child: Text(
                  '${_formatTime(message.createdAt)} · ${read ? '已读' : '已发送'}',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime utcTime) {
    final time = utcTime.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(time.hour)}:${two(time.minute)}';
  }
}

/// 通话记录消息：微信式居中系统提示，不区分收发双方
/// 文本由服务端生成，如“[语音通话] 已取消”“[视频通话] 通话时长 05:32”
class _CallMessageChip extends StatelessWidget {
  const _CallMessageChip({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isVideo = message.text.startsWith('[视频通话]');
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isVideo ? Icons.videocam_outlined : Icons.call_outlined,
                size: 14,
                color: AppColors.onSurfaceVariant,
              ),
              SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  message.text,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 待确认消息气泡：发送中或可点击重试
class _PendingBubble extends StatelessWidget {
  const _PendingBubble({
    required this.message,
    required this.sending,
    required this.onRetry,
  });

  final PendingMessage message;
  final bool sending;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.72;
    final bubble = Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message.text,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurface),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            bubble,
            if (sending)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs, right: AppSpacing.xs),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      '发送中',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              )
            else
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  minimumSize: const Size(44, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppColors.error,
                  textStyle: AppTypography.bodySmall,
                ),
                child: const Text('未发送，点击重试'),
              ),
          ],
        ),
      ),
    );
  }
}
