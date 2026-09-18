import 'package:dio/dio.dart';
import 'package:native_app/core/network/api_exception.dart';
import 'package:native_app/core/network/api_interceptor.dart';

import '../models/chat_models.dart';

abstract interface class ChatRemoteDataSource {
  Future<String> verifyUser();
  Future<ChatConversation> direct(String peerUserId);
  Future<ChatConversationPage> conversations({String? beforeId});
  Future<ChatMessagePage> history(String id, {String? beforeSeq});
  Future<ChatMessagePage> sync(String id, int afterSeq);
  Future<ChatMessage> send(PendingMessage message);
  Future<int> read(String id, int seq);
  Future<MqttCredentials> credentials(String deviceId);
  void cancel();
}

class DioChatRemoteDataSource implements ChatRemoteDataSource {
  DioChatRemoteDataSource(this._dio, this.epoch);
  final Dio _dio;
  final int epoch;
  final _cancel = CancelToken();
  static const _base = '/app/chat/conversations';

  Future<Map<String, dynamic>> _request(String path, {String method = 'GET',
    Map<String, dynamic>? data, Map<String, dynamic>? query}) async {
    final response = await _dio.request<Map<String, dynamic>>(path,
      data: data, queryParameters: query, cancelToken: _cancel,
      options: Options(method: method, extra: {ApiInterceptor.sessionEpochKey: epoch}),
    );
    final body = response.data;
    if (body == null || body['code'] != 200) {
      throw ApiException(code: body?['code'] is num ? (body!['code'] as num).toInt() : null,
        message: body?['msg'] as String? ?? '请求失败，请重试');
    }
    return Map<String, dynamic>.from(body['data'] as Map);
  }

  @override
  Future<String> verifyUser() async => wireId((await _request('/app/auth/me'))['id']);
  @override
  Future<ChatConversation> direct(String peerUserId) async => ChatConversation.fromJson(
    await _request('$_base/direct', method: 'POST', data: {'peerUserId': peerUserId}));
  @override
  Future<ChatConversationPage> conversations({String? beforeId}) async => ChatConversationPage.fromJson(
    await _request(_base, query: {'beforeId': ?beforeId, 'limit': 50}));
  @override
  Future<ChatMessagePage> history(String id, {String? beforeSeq}) async => ChatMessagePage.fromJson(
    await _request('$_base/${Uri.encodeComponent(id)}/messages', query: {
      'beforeSeq': ?beforeSeq, 'limit': 50}));
  @override
  Future<ChatMessagePage> sync(String id, int afterSeq) async => ChatMessagePage.fromJson(
    await _request('$_base/${Uri.encodeComponent(id)}/sync', query: {'afterSeq': '$afterSeq', 'limit': 100}));
  @override
  Future<ChatMessage> send(PendingMessage message) async => ChatMessage.fromJson(
    await _request('$_base/${Uri.encodeComponent(message.conversationId)}/messages', method: 'POST',
      data: {'clientMsgId': message.clientMsgId, 'text': message.text}));
  @override
  Future<int> read(String id, int seq) async => wireSeq((await _request(
    '$_base/${Uri.encodeComponent(id)}/read', method: 'PUT', data: {'seq': '$seq'}))['readSeq']);
  @override
  Future<MqttCredentials> credentials(String deviceId) async => MqttCredentials.fromJson(
    await _request('/app/realtime/mqtt-credentials', method: 'POST', data: {'deviceId': deviceId}));
  @override
  void cancel() => _cancel.cancel('账号会话已结束');
}
