import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'api_exception.dart';
import 'token_manager.dart';

/// API 拦截器
/// 负责 Token 注入、401 自动刷新、响应处理
class ApiInterceptor extends Interceptor {
  final TokenManager _tokenManager;
  final Logger _logger;
  final Dio _dio;

  Future<String?>? _refreshing;
  int? _refreshEpoch;
  static const sessionEpochKey = 'sessionEpoch';
  static const _retried = 'authRetried';

  ApiInterceptor({
    required this._tokenManager,
    required this._dio,
    Logger? logger,
  })  : _logger = logger ?? Logger();

  /// 内部请求标记：跳过 Authorization 自动注入（用于刷新 Token 等请求，
  /// 避免被过期 Access Token 覆盖）
  static const _kSkipAuth = 'skipAuth';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra.putIfAbsent(sessionEpochKey, () => _tokenManager.sessionEpoch);
    if (options.extra[sessionEpochKey] != _tokenManager.sessionEpoch) {
      handler.reject(DioException(requestOptions: options, type: DioExceptionType.cancel));
      return;
    }
    // 内部请求（如刷新 Token）跳过 Authorization 自动注入
    if (options.extra[_kSkipAuth] != true) {
      final authHeader = _tokenManager.authorizationHeader;
      if (authHeader != null) {
        options.headers['Authorization'] = authHeader;
      }
    }

    _logger.d('Request: ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d('Response: ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final epoch = options.extra[sessionEpochKey];
    final internal = options.extra[_kSkipAuth] == true ||
        options.path == '/app/auth/refresh' ||
        options.path.startsWith('/app/auth/login');
    if (err.response?.statusCode == 401 && !internal &&
        epoch == _tokenManager.sessionEpoch && options.extra[_retried] != true &&
        _tokenManager.hasRefreshToken) {
      // 迟到的旧令牌 401 直接使用已刷新的令牌，不发起第二轮刷新。
      String? failure;
      if (options.headers['Authorization'] == _tokenManager.authorizationHeader) {
        if (_refreshing == null || _refreshEpoch != epoch) {
          _refreshEpoch = epoch as int;
          final future = _refreshToken();
          _refreshing = future;
          future.then((_) {
            if (identical(_refreshing, future)) _refreshing = null;
          });
        }
        failure = await _refreshing!;
      }
      if (epoch != _tokenManager.sessionEpoch || options.cancelToken?.isCancelled == true) {
        handler.reject(DioException(requestOptions: options, type: DioExceptionType.cancel));
        return;
      }
      if (failure == null) {
        options.extra[_retried] = true;
        await _retryRequest(err, handler);
        return;
      }
      // 每个等待者都会结束；清理失败也不能让 Dio handler 悬挂。
      try {
        await _tokenManager.clearTokens();
      } catch (_) {
        // 内存中的认证状态已同步清除。
      }
      handler.reject(DioException(requestOptions: options, error: ApiException(
        code: 401, type: ApiExceptionType.unauthorized, message: failure,
      )));
      return;
    }

    // 其他错误，转换为 ApiException
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: ApiException.fromDioException(err),
      ),
    );
  }

  /// 刷新 Token
  ///
  /// 通过 refreshToken 调用 `/api/app/auth/refresh` 换取新的双 Token。
  /// 返回 `null` 表示刷新成功；返回非空字符串表示失败原因
  /// （优先透传后端 `msg`，如「刷新令牌无效或已过期」）。
  Future<String?> _refreshToken() async {
    try {
      final epoch = _tokenManager.sessionEpoch;
      final refreshToken = _tokenManager.refreshToken;
      if (refreshToken == null) return '登录已过期，请重新登录';

      final response = await _dio.post(
        '/app/auth/refresh',
        data: {'refreshToken': refreshToken},
        // 标记为内部请求，跳过 onRequest 中对 Authorization 的自动注入，
        // 避免过期的 Access Token 覆盖本次刷新请求
        options: Options(extra: const {_kSkipAuth: true}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data as Map<String, dynamic>;
        final code = body['code'] as int?;
        if (code == 200) {
          final data = body['data'] as Map<String, dynamic>?;
          final newAccessToken = data?['accessToken'] as String?;
          final newRefreshToken = data?['refreshToken'] as String?;
          if (newAccessToken != null && epoch == _tokenManager.sessionEpoch) {
            await _tokenManager.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken ?? refreshToken,
              isRefresh: true,
            );
            return null;
          }
        }
        // 业务失败：透传后端具体原因
        final msg = body['msg'] as String?;
        return (msg != null && msg.isNotEmpty) ? msg : '登录已过期，请重新登录';
      }
      return '登录已过期，请重新登录';
    } catch (e) {
      _logger.w('刷新令牌失败');
      return 'Token 刷新失败';
    }
  }

  /// 重试失败的请求
  Future<void> _retryRequest(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final options = err.requestOptions;

      // 更新 Authorization Header
      final authHeader = _tokenManager.authorizationHeader;
      if (authHeader != null) {
        options.headers['Authorization'] = authHeader;
      }

      // 重试请求
      final response = await _dio.fetch(options);
      handler.resolve(response);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: e,
        ),
      );
    }
  }
}
