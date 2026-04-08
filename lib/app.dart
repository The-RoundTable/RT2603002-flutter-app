import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/apptheme.dart';

// ConsumerWidget = A widget that can READ Riverpod providers
// Use this instead of StatelessWidget when you need providers
class DMSApp extends ConsumerWidget {
  const DMSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref is your access point to ALL providers
    // ref.watch()  → listens and rebuilds when value changes
    // ref.read()   → reads once, no rebuild (use in callbacks)
    // ref.listen() → side effects when value changes
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Driver Monitoring System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // We use dark theme for this app
      routerConfig: router,
    );
  }
}