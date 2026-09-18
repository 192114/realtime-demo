import 'call_models.dart';

/// 通话页路由参数：状态与连接凭证只经路由 extra 在页面间传递
class CallRouteArgs {
  const CallRouteArgs({required this.call, required this.token, required this.liveKitUrl});

  final CallSession call;
  final String token;
  final String liveKitUrl;
}
