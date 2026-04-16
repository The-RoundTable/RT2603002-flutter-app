import 'package:driver_management_system/features/dashboard/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ThemeData.dark().scaffoldBackgroundColor,

      // appBar: AppBar(
      //   title: const Text('Dashboard'),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.logout),
      //       onPressed: () {
      //         ref.read(authActionsProvider.notifier).logout();
      //       },
      //     ),
      //   ],
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(ref, size.width < 400),
              const SizedBox(height: 24),
              // Placeholder for future dashboard content
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Welcome to your dashboard!',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(WidgetRef ref, bool isSmall) {
    final name = ref.watch(driverNameProvider);
    final greeting = ref.watch(greetingProvider);

    // return Row(
    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //   children: [
    //     Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text(
    //           greeting,
    //           style: TextStyle(
    //             fontSize: isSmall ? 12 : 13,
    //             color: Colors.white.withValues(alpha: 0.4),
    //             letterSpacing: 0.5,
    //           ),
    //         ),
    //         const SizedBox(height: 2),
    //         Text(
    //           name,
    //           style: TextStyle(
    //             fontSize: isSmall ? 20 : 24,
    //             fontWeight: FontWeight.w700,
    //             color: Colors.white,
    //             letterSpacing: -0.5,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ],
    // );
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: TextStyle(
              fontSize: isSmall ? 12 : 13,
              color: Colors.white.withValues(alpha: 0.4),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            name,
            style: TextStyle(
              fontSize: isSmall ? 20 : 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            ref.read(authActionsProvider.notifier).logout();
          },
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }
}
