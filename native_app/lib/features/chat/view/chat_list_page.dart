import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:native_app/config/theme/app_colors.dart';
import 'package:native_app/config/theme/app_spacing.dart';
import 'package:native_app/config/theme/app_typography.dart';
import 'package:native_app/shared/widgets/message/message.dart';

import '../models/chat_models.dart';
import '../repositories/chat_realtime_coordinator.dart';
import '../view_model/chat_view_models.dart';
import '../widgets/chat_offline_banner.dart';

/// 会话列表页
class ChatListPage extends ConsumerWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatHomeViewModelProvider);

    ref.listen<ChatHomeState>(chatHomeViewModelProvider, (prev, next) {
      if (next.errorSeq != prev?.errorSeq) {
        AppMessage.error(next.actionError!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天'),
        actions: [
          IconButton(
            tooltip: '发起聊天',
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () => _showCreateDialog(context, ref),
          ),
        ],
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ChatHomeState state) {
    if (state.repository == null) {
      if (state.initializing || state.errorMessage == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: AppColors.outline),
            SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.onSurfaceVariant),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () =>
                  ref.read(chatHomeViewModelProvider.notifier).retryInitialize(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        if (state.connection == ChatConnection.offline)
          ChatOfflineBanner(
            onRetry: () =>
                ref.read(chatHomeViewModelProvider.notifier).retryConnection(),
          ),
        Expanded(
          child: state.conversations.isEmpty
              ? _EmptyView(onStart: () => _showCreateDialog(context, ref))
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(chatHomeViewModelProvider.notifier).refresh(),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.conversations.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, indent: 72, endIndent: 16),
                    itemBuilder: (context, index) => _ConversationTile(
                      conversation: state.conversations[index],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('发起聊天'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '对方用户 ID',
              hintText: '输入对方的用户 ID 开始单聊',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                final peerUserId = controller.text.trim();
                if (peerUserId.isEmpty) return;
                Navigator.pop(dialogContext);
                final conversationId = await ref
                    .read(chatHomeViewModelProvider.notifier)
                    .createDirect(peerUserId);
                if (conversationId != null && context.mounted) {
                  unawaited(context.push('/chat/$conversationId'));
                }
              },
              child: const Text('发起'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }
}

/// 空会话占位视图
class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 56, color: AppColors.outline),
          SizedBox(height: AppSpacing.md),
          Text('还没有会话', style: AppTypography.titleMedium),
          SizedBox(height: AppSpacing.sm),
          Text(
            '输入对方用户 ID，发起第一个单聊',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.onSurfaceVariant),
          ),
          SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.add_comment_outlined, size: 18),
            label: const Text('发起聊天'),
          ),
        ],
      ),
    );
  }
}

/// 会话列表项
class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation});

  final ChatConversation conversation;

  @override
  Widget build(BuildContext context) {
    final title = conversation.peerNickname ?? conversation.peerUserId;
    final unread = conversation.unreadCount;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.xs,
      ),
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryContainer,
        child: Text(
          title.substring(0, 1),
          style: AppTypography.titleMedium
              .copyWith(color: AppColors.onPrimaryContainer),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleMedium,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            _formatTime(conversation.updatedAt),
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
      subtitle: Text(
        conversation.lastMessage ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.bodyMedium
            .copyWith(color: AppColors.onSurfaceVariant),
      ),
      trailing: unread > 0
          ? Badge(
              backgroundColor: AppColors.error,
              label: Text(unread > 99 ? '99+' : '$unread'),
            )
          : null,
      onTap: () => unawaited(
        context.push('/chat/${conversation.conversationId}'),
      ),
    );
  }

  String _formatTime(DateTime utcTime) {
    final time = utcTime.toLocal();
    final now = DateTime.now();
    final sameDay = time.year == now.year &&
        time.month == now.month &&
        time.day == now.day;
    String two(int value) => value.toString().padLeft(2, '0');
    if (sameDay) return '${two(time.hour)}:${two(time.minute)}';
    return '${two(time.month)}-${two(time.day)}';
  }
}
