import 'package:driver_management_system/features/dashboard/providers/session_provider.dart';
import 'package:driver_management_system/features/dashboard/widgets/recent_events_ticker.dart';
import 'package:driver_management_system/features/dashboard/widgets/risk_gauge.dart';
import 'package:driver_management_system/features/dashboard/widgets/session_button.dart';
import 'package:driver_management_system/features/dashboard/widgets/status_cards_grid.dart';
import 'package:driver_management_system/features/dashboard/providers/user_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sessionAsync = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      body: SafeArea(
        child: sessionAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF00E676)),
          ),
          error: (e, _) => Center(
            child: Text(
              'Error: $e',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
          data: (session) => _buildBody(session, size),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody(SessionState session, Size size) {
    final isSmall = size.width < 400;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //  Step 2: App bar 
          _buildAppBar(ref, isSmall),
          const SizedBox(height: 20),

          //  Step 3: Risk gauge 
          _buildGaugeSection(session),
          const SizedBox(height: 24),

          //  Step 4: Start/End session button
          SessionButton(
            isActive: session.isActive,
            onStart: () => ref.read(sessionProvider.notifier).startSession(),
            onEnd: () => ref.read(sessionProvider.notifier).endSession(),
          ),
          const SizedBox(height: 28),

          //  Step 5: Status cards 
          _buildSectionHeader('Detection Status'),
          const SizedBox(height: 12),
          StatusCardsGrid(
            cardStates: session.cardStates,
            isActive: session.isActive,
          ),
          const SizedBox(height: 28),

          //  Step 6: Recent events ticker 
          _buildSectionHeader(
            'Recent Events',
            trailing: session.recentEvents.isNotEmpty
                ? Text(
                    '${session.recentEvents.length} events',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          RecentEventsTicker(events: session.recentEvents),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  //  Step 3 helper: gauge + session duration 

  Widget _buildGaugeSection(SessionState session) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          // Section label
          Text(
            'RISK LEVEL',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.3),
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 12),

          // Gauge
          Center(
            child: RiskGauge(
              riskScore: session.riskScore,
              severity: session.currentSeverity,
              isActive: session.isActive,
            ),
          ),

          // Session duration
          if (session.isActive && session.startTime != null) ...[
            const SizedBox(height: 12),
            _SessionTimer(startTime: session.startTime!),
          ],
        ],
      ),
    );
  }

  //  App bar 

  Widget _buildAppBar(WidgetRef ref, bool isSmall) {
    final name = ref.watch(driverNameProvider);
    final greeting = ref.watch(greetingProvider);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
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
          tooltip: 'Logout',
          onPressed: () {
            ref.read(authActionsProvider.notifier).logout();
          },
          icon: const Icon(Icons.logout, color: Colors.white54),
        ),
      ],
    );
  }

  //  Section header 

  Widget _buildSectionHeader(String title, {Widget? trailing}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        if (trailing != null) ...[const Spacer(), trailing],
      ],
    );
  }

  // Step 6: Bottom navigation 

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D12),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.07),
            width: 1,
          ),
        ),
      ),
      child: NavigationBar(
        backgroundColor: Colors.transparent,
        indicatorColor: const Color(0xFF00E676).withValues(alpha: 0.12),
        selectedIndex: _currentNavIndex,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (index) {
          setState(() => _currentNavIndex = index);
          
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, color: Colors.white38),
            selectedIcon: Icon(
              Icons.dashboard_rounded,
              color: Color(0xFF00E676),
            ),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined, color: Colors.white38),
            selectedIcon: Icon(
              Icons.bar_chart_rounded,
              color: Color(0xFF00E676),
            ),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined, color: Colors.white38),
            selectedIcon: Icon(
              Icons.notifications_rounded,
              color: Color(0xFF00E676),
            ),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: Colors.white38),
            selectedIcon: Icon(
              Icons.settings_rounded,
              color: Color(0xFF00E676),
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

//  Session timer widget 

class _SessionTimer extends StatefulWidget {
  final DateTime startTime;
  const _SessionTimer({required this.startTime});

  @override
  State<_SessionTimer> createState() => _SessionTimerState();
}

class _SessionTimerState extends State<_SessionTimer> {
  late final Stream<DateTime> _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: _ticker,
      builder: (context, _) {
        final elapsed = DateTime.now().difference(widget.startTime);
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer_outlined, size: 12, color: Colors.white24),
            const SizedBox(width: 5),
            Text(
              'Session: ${_formatDuration(elapsed)}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.3),
                letterSpacing: 0.5,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        );
      },
    );
  }
}
