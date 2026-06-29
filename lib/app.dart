import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/apptheme.dart';


class DMSApp extends ConsumerWidget {
  const DMSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Driver Monitoring System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, 
      routerConfig: router,
    );
  }
}