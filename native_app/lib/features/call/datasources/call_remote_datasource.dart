import 'package:dio/dio.dart';
import 'package:native_app/core/network/api_exception.dart';
import 'package:native_app/core/network/api_interceptor.dart';

import '../models/call_models.dart';

abstract interface class CallRemoteDataSource {
  Future<CallSession> initiate(String calleeId, String mediaType);
  Future<CallSession> accept(String callId);
  Future<CallSession> reject(String callId);
  Future<CallSession> cancel(String callId);
  Future<CallSession> end(String callId);
  Future<CallSession?> active();
  Future<CallRecordPage> records({String? beforeId});
  void close();
}

class DioCallRemoteDataSource implements CallRemoteDataSource {
  DioCallRemoteDataSource(this._dio, this.epoch);
  final Dio _dio;
  final int epoch;
  final _cancel = CancelToken();
  static const _base = '/app/call';

  Future<Map<String, dynamic>?> _request(String path, {String method = 'GET',
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
    final payload = body['data'];
    return payload is Map ? Map<String, dynamic>.from(payload) : null;
  }

  Future<CallSession> _require(String path, {String method = 'GET',
      Map<String, dynamic>? data, Map<String, dynamic>? query}) async {
    final payload = await _request(path, method: method, data: data, query: query);
    if (payload == null) throw const ApiException(code: null, message: '响应缺少通话数据');
    return CallSession.fromJson(payload);
  }

  @override
  Future<CallSession> initiate(String calleeId, String mediaType) async => _require('$_base/direct',
    method: 'POST', data: {'calleeId': calleeId, 'mediaType': mediaType});

  @override
  Future<CallSession> accept(String callId) async => _require(
    '$_base/${Uri.encodeComponent(callId)}/accept', method: 'POST');

  @override
  Future<CallSession> reject(String callId) async => _require(
    '$_base/${Uri.encodeComponent(callId)}/reject', method: 'POST');

  @override
  Future<CallSession> cancel(String callId) async => _require(
    '$_base/${Uri.encodeComponent(callId)}/cancel', method: 'POST');

  @override
  Future<CallSession> end(String callId) async => _require(
    '$_base/${Uri.encodeComponent(callId)}/end', method: 'POST');

  @override
  Future<CallSession?> active() async {
    final payload = await _request('$_base/active');
    return payload == null ? null : CallSession.fromJson(payload);
  }

  @override
  Future<CallRecordPage> records({String? beforeId}) async {
    final payload = await _request('$_base/records', query: {'beforeId': ?beforeId, 'limit': 50});
    if (payload == null) throw const ApiException(code: null, message: '响应缺少通话记录');
    return CallRecordPage.fromJson(payload);
  }

  @override
  void close() => _cancel.cancel('账号会话已结束');
}
