import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_app/core/network/api_interceptor.dart';
import 'package:native_app/core/network/token_manager.dart';
import 'package:native_app/core/storage/secure_storage.dart';

class MemoryStorage extends SecureStorage {
  final values = <String, String>{};
  @override
  Future<void> write({required String key, required String value}) async { values[key] = value; }
  @override
  Future<void> delete({required String key}) async { values.remove(key); }
}

class Adapter implements HttpClientAdapter {
  Adapter(this.respond);
  final Future<ResponseBody> Function(RequestOptions) respond;
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream,
      Future<void>? cancelFuture) => respond(options);
  @override
  void close({bool force = false}) {}
}

ResponseBody body(int status, [Map<String, dynamic>? data]) => ResponseBody.fromString(
  jsonEncode(data ?? {'code': status, 'msg': '拒绝'}), status,
  headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
);

void main() {
  late TokenManager tokens;
  late Dio dio;
  setUp(() async {
    tokens = TokenManager(secureStorage: MemoryStorage());
    await tokens.saveTokens(accessToken: 'old', refreshToken: 'refresh');
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'));
    dio.interceptors.add(ApiInterceptor(tokenManager: tokens, dio: dio));
  });
  tearDown(() => dio.close(force: true));

  test('refresh 自身 401 不死锁，并发等待者全部结束', () async {
    var refreshes = 0;
    dio.httpClientAdapter = Adapter((options) async {
      if (options.path.endsWith('/refresh')) {
        refreshes++;
        await Future<void>.delayed(const Duration(milliseconds: 30));
      }
      return body(401);
    });
    final results = await Future.wait(List.generate(5, (_) async {
      try { await dio.get('/app/chat/conversations'); return false; }
      on DioException { return true; }
    })).timeout(const Duration(seconds: 2));
    expect(results, everyElement(isTrue));
    expect(refreshes, 1);
    expect(tokens.hasToken, isFalse);
  });

  test('成功刷新后最多重试一次且不改变账号代际', () async {
    var refreshes = 0;
    var requests = 0;
    final epoch = tokens.sessionEpoch;
    dio.httpClientAdapter = Adapter((options) async {
      if (options.path.endsWith('/refresh')) {
        refreshes++;
        return body(200, {'code': 200, 'data': {'accessToken': 'new', 'refreshToken': 'new-r'}});
      }
      requests++;
      return body(401);
    });
    await expectLater(dio.get('/app/chat/conversations').timeout(const Duration(seconds: 2)), throwsA(isA<DioException>()));
    expect(refreshes, 1);
    expect(requests, 2);
    expect(tokens.sessionEpoch, epoch);
  });

  test('旧账号刷新结果不能复活登录态或覆盖新账号', () async {
    final started = Completer<void>();
    final release = Completer<void>();
    dio.httpClientAdapter = Adapter((options) async {
      if (options.path.endsWith('/refresh')) {
        started.complete();
        await release.future;
        return body(200, {'code': 200, 'data': {'accessToken': 'stale'}});
      }
      return body(401);
    });
    final request = dio.get('/app/chat/conversations');
    final expectation = expectLater(request, throwsA(isA<DioException>()));
    await started.future;
    await tokens.clearTokens();
    await tokens.saveTokens(accessToken: 'account-b', refreshToken: 'b-r');
    release.complete();
    await expectation;
    expect(tokens.accessToken, 'account-b');
  });
}
