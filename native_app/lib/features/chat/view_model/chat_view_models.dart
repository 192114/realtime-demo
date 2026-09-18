import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:native_app/core/network/api_exception.dart';

import '../chat_session_manager.dart';
import '../models/chat_models.dart';
import '../repositories/chat_realtime_coordinator.dart';
import '../repositories/chat_repository.dart';

part 'chat_view_models.freezed.dart';

// ==================== 会话列表 ====================

@freezed
abstract class ChatHomeState with _$ChatHomeState {
  const factory ChatHomeState({
    ChatRepository? repository,
    @Default(ChatConnection.background) ChatConnection connection,
    @Default(false) bool initializing,
    String? errorMessage,
    @Default([]) List<ChatConversation> conversations,
    String? actionError,
    @Default(0) int errorSeq,
  }) = _ChatHomeState;
}

class ChatHomeViewModel extends Notifier<ChatHomeState> {
  bool _alive = true;

  @override
  ChatHomeState build() {
    _alive = true;
    final manager = chatSessionManager.attach();
    manager.addListener(_onManagerChanged);
    ref.onDispose(() {
      _alive = false;
      manager.removeListener(_onManagerChanged);
    });
    unawaited(_bootstrap());
    return ChatHomeState(
      repository: manager.repository,
      connection: manager.connection,
      initializing: manager.initializing,
      errorMessage: manager.errorMessage,
    );
  }

  Future<void> _bootstrap() async {
    await chatSessionManager.ensure();
    if (!_alive) return;
    _onManagerChanged();
  }

  void _onManagerChanged() {
    if (!_alive) return;
    final manager = chatSessionManager;
    // 直接构造新状态，避免 copyWith 无法把可空字段置回 null
    state = ChatHomeState(
      repository: manager.repository,
      connection: manager.connection,
      initializing: manager.initializing,
      errorMessage: manager.errorMessage,
      conversations: state.conversations,
      actionError: state.actionError,
      errorSeq: state.errorSeq,
    );
    if (manager.repository != null) unawaited(_reload());
  }

  Future<void> _reload() async {
    final repository = chatSessionManager.repository;
    if (repository == null || !_alive) return;
    try {
      final conversations = await repository.conversations();
      if (!_alive || repository != chatSessionManager.repository) return;
      state = state.copyWith(conversations: conversations);
    } catch (_) {
      // 会话已结束或本地库已关闭：随代际通知重建
    }
  }

  /// 初始化失败后重试
  Future<void> retryInitialize() async {
    await chatSessionManager.ensure();
    if (_alive) _onManagerChanged();
  }

  /// 创建（或获取已有）单聊会话；成功返回会话 ID，失败返回 null
  Future<String?> createDirect(String peerUserId) async {
    final repository = state.repository ?? await _ensureStarted();
    if (repository == null) return null;
    try {
      final conversation = await repository.direct(peerUserId);
      if (_alive) unawaited(_reload());
      return conversation.conversationId;
    } on ApiException catch (error) {
      _actionError(error.message);
    } on ArgumentError catch (error) {
      _actionError(error.message?.toString() ?? '请输入其他用户的 ID');
    } catch (_) {
      _actionError('发起会话失败，请稍后重试');
    }
    return null;
  }

  /// 下拉刷新会话列表
  Future<void> refresh() async {
    final repository = state.repository;
    if (repository == null) return;
    try {
      await repository.refreshConversations();
    } catch (_) {
      // 保留本地缓存展示；实时协调器会继续补拉
    }
    if (_alive) unawaited(_reload());
  }

  /// 离线时点击提示条立即重试
  void retryConnection() => chatSessionManager.retry();

  Future<ChatRepository?> _ensureStarted() async {
    await chatSessionManager.ensure();
    if (!_alive) return null;
    _onManagerChanged();
    return state.repository;
  }

  void _actionError(String message) {
    if (!_alive) return;
    state = state.copyWith(actionError: message, errorSeq: state.errorSeq + 1);
  }
}

final chatHomeViewModelProvider =
    NotifierProvider<ChatHomeViewModel, ChatHomeState>(ChatHomeViewModel.new);

// ==================== 聊天详情 ====================

@freezed
abstract class ChatDetailState with _$ChatDetailState {
  const factory ChatDetailState({
    ChatRepository? repository,
    String? myUserId,
    String? peerUserId,
    String? peerNickname,
    @Default(0) int peerReadSeq,
    @Default(ChatConnection.background) ChatConnection connection,
    @Default([]) List<ChatMessage> messages,
    @Default([]) List<PendingMessage> pending,
    @Default(<String>{}) Set<String> sending,
    @Default(true) bool hasMore,
    @Default(false) bool loadingMore,
    String? actionError,
    @Default(0) int errorSeq,
  }) = _ChatDetailState;
}

class ChatDetailViewModel extends Notifier<ChatDetailState> {
  ChatDetailViewModel(this.conversationId);

  /// 会话 ID（由 provider 按 family 参数构造传入）
  final String conversationId;

  bool _alive = true;
  int _limit = 50;

  @override
  ChatDetailState build() {
    _alive = true;
    final manager = chatSessionManager.attach();
    manager.addListener(_onManagerChanged);
    ref.onDispose(() {
      _alive = false;
      manager.removeListener(_onManagerChanged);
    });
    unawaited(_bootstrap());
    return ChatDetailState(
      repository: manager.repository,
      myUserId: manager.repository?.userId,
    );
  }

  Future<void> _bootstrap() async {
    await chatSessionManager.ensure();
    if (!_alive) return;
    _onManagerChanged();
    final repository = chatSessionManager.repository;
    if (repository == null) return;
    try {
      // 进入详情页先增量同步一次；协调器与 HTTP 轮询负责兜底
      await repository.sync(conversationId);
    } catch (_) {
      // 同步失败不阻塞页面：本地数据仍然可展示
    }
    if (_alive) unawaited(_reload());
  }

  void _onManagerChanged() {
    if (!_alive) return;
    final manager = chatSessionManager;
    final repository = manager.repository;
    if (repository != state.repository) {
      // 仓库重建（登录代际变化）时重置数据
      state = ChatDetailState(
        repository: repository,
        myUserId: repository?.userId,
        connection: manager.connection,
      );
      _limit = 50;
    } else {
      state = state.copyWith(connection: manager.connection);
    }
    if (repository != null) unawaited(_reload());
  }

  Future<void> _reload() async {
    final repository = chatSessionManager.repository;
    if (repository == null || !_alive) return;
    final id = conversationId;
    try {
      final conversation = (await repository.conversations())
          .where((item) => item.conversationId == id)
          .firstOrNull;
      final messages = await repository.messages(id, limit: _limit);
      final pending = (await repository.pending())
          .where((item) => item.conversationId == id)
          .toList();
      final previous = state;
      if (!_alive || repository != chatSessionManager.repository) return;
      state = ChatDetailState(
        repository: repository,
        myUserId: repository.userId,
        peerUserId: conversation?.peerUserId,
        peerNickname: conversation?.peerNickname,
        peerReadSeq: conversation?.peerReadSeq ?? 0,
        connection: previous.connection,
        messages: messages,
        pending: pending,
        sending: previous.sending,
        hasMore: previous.hasMore,
        loadingMore: previous.loadingMore,
        actionError: previous.actionError,
        errorSeq: previous.errorSeq,
      );
      final cursor = await repository.cursor(id);
      if (!_alive) return;
      // 进入会话即视为读到本地连续游标；服务端确认后回填 readSeq
      if (cursor > (conversation?.readSeq ?? 0)) {
        unawaited(repository.markRead(id, cursor, stillVisible: () => _alive));
      }
    } catch (_) {
      // 会话已结束或本地库已关闭：随代际通知重建
    }
  }

  /// 向上滚动加载历史消息
  Future<void> loadMore() async {
    final repository = state.repository;
    if (repository == null) return;
    final id = conversationId;
    if (state.loadingMore || !state.hasMore || state.messages.isEmpty) return;
    final oldest = state.messages.last;
    state = state.copyWith(loadingMore: true);
    try {
      final hasMore = await repository.history(id, beforeSeq: '${oldest.seq}');
      if (!_alive) return;
      _limit += 50;
      state = state.copyWith(hasMore: hasMore, loadingMore: false);
      unawaited(_reload());
    } catch (_) {
      if (_alive) {
        state = state.copyWith(loadingMore: false);
        _actionError('加载历史消息失败，请稍后重试');
      }
    }
  }

  /// 发送文本消息：先落盘再发送；失败时保留待重试状态
  Future<void> send(String text) async {
    final repository = state.repository;
    if (repository == null) return;
    final id = conversationId;
    PendingMessage? draft;
    try {
      draft = repository.draft(id, text);
      state = state.copyWith(sending: {...state.sending, draft.clientMsgId});
      try {
        await repository.send(draft);
      } finally {
        if (_alive) {
          state = state.copyWith(
            sending: {...state.sending}..remove(draft.clientMsgId),
          );
        }
      }
    } on ChatPersistenceException catch (error) {
      _actionError(error.toString());
    } on ArgumentError catch (error) {
      _actionError(error.message?.toString() ?? '请输入消息');
    } on ApiException catch (error) {
      _actionError(error.message);
    } on StateError {
      // 账号会话已结束：随登录态跳转处理
    } catch (_) {
      _actionError('发送失败，消息已保存；可点击消息重试');
    }
  }

  /// 重试一条未确认消息（同一 clientMsgId，服务端幂等去重）
  Future<void> retryPending(PendingMessage message) async {
    final repository = state.repository;
    if (repository == null) return;
    if (state.sending.contains(message.clientMsgId)) return;
    state = state.copyWith(sending: {...state.sending, message.clientMsgId});
    try {
      await repository.send(message);
    } on ChatPersistenceException catch (error) {
      _actionError(error.toString());
    } on ApiException catch (error) {
      _actionError(error.message);
    } on StateError {
      // 账号会话已结束
    } catch (_) {
      _actionError('发送失败，请稍后重试');
    } finally {
      if (_alive) {
        state = state.copyWith(
          sending: {...state.sending}..remove(message.clientMsgId),
        );
      }
    }
  }

  /// 离线时点击提示条立即重试
  void retryConnection() => chatSessionManager.retry();

  void _actionError(String message) {
    if (!_alive) return;
    state = state.copyWith(actionError: message, errorSeq: state.errorSeq + 1);
  }
}

final chatDetailViewModelProvider = NotifierProvider.family<
    ChatDetailViewModel, ChatDetailState, String>(ChatDetailViewModel.new);
