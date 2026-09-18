import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'config/theme/app_colors.dart';
import 'config/theme/app_typography.dart';
import 'core/router/app_router.dart';
import 'features/call/call_coordinator.dart';
import 'features/chat/chat_session_manager.dart';

/// 应用入口 Widget
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  late final GoRouter _router;
  String? _navigatedIncomingCallId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _router = AppRouter.createRouter();
    // 启动时同步前台状态；后续生命周期变化驱动实时连接与来电轮询的启停
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    final foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    chatSessionManager.setForeground(foreground);
    callCoordinator.attach();
    callCoordinator.setForeground(foreground);
    callCoordinator.addListener(_onIncomingCall);
  }

  @override
  void dispose() {
    callCoordinator.removeListener(_onIncomingCall);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 前台保持实时连接与来电轮询；后台断开，不做长连接保活
    final foreground = state == AppLifecycleState.resumed;
    chatSessionManager.setForeground(foreground);
    callCoordinator.setForeground(foreground);
  }

  void _onIncomingCall() {
    final incoming = callCoordinator.incoming;
    if (incoming == null || _navigatedIncomingCallId == incoming.callId) return;
    _navigatedIncomingCallId = incoming.callId;
    _router.push(RoutePaths.callIncoming, extra: incoming);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Native App',
      debugShowCheckedModeBanner: false,

      // 主题配置
      theme: ThemeData(
        colorScheme: AppColors.lightColorScheme,
        textTheme: AppTypography.textTheme,
        useMaterial3: true,
      ),

      // 路由配置
      routerConfig: _router,
    );
  }
}
