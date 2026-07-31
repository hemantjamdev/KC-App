import 'package:flutter/material.dart';
import '../core/widgets/network_listener_wrapper.dart';
import 'app_routes.dart';
import 'app_theme.dart';

/// Root application widget for Kapada Creation Customer application.
class KcApp extends StatelessWidget {
  const KcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kapada Creation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      builder: (context, child) => NetworkListenerWrapper(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
