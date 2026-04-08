import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────
// WHAT CHANGED AND WHY:
//
// Old version had ref.listen() trying to navigate manually.
// That conflicted with GoRouter's own redirect logic.
// Two things were trying to navigate at the same time → stuck.
//
// Fix: SplashScreen does ZERO navigation.
// It only shows the animation + loading state.
// GoRouter's redirect (via _RouterNotifier) handles ALL navigation.
// When authProvider finishes loading → notifier fires →
// GoRouter redirects automatically to /login or /dashboard.
// ─────────────────────────────────────────────────────────

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _textController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _pulseScale;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) _textController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Just WATCH the auth state to show correct status text
    // Navigation is handled entirely by GoRouter — not here
    final authAsync = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      body: Stack(
        children: [
          CustomPaint(size: size, painter: _GridPainter()),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogoSection(size, isSmall),
                SizedBox(height: size.height * 0.06),
                _buildTextSection(isSmall),
                SizedBox(height: size.height * 0.08),
                _buildLoadingSection(authAsync, isSmall),
              ],
            ),
          ),

          _buildVersionText(size),
        ],
      ),
    );
  }

  Widget _buildLogoSection(Size size, bool isSmall) {
    final logoSize = (size.width * 0.28).clamp(90.0, 140.0);

    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _pulseController]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _logoOpacity,
          child: ScaleTransition(
            scale: _logoScale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: _pulseScale.value,
                  child: Container(
                    width: logoSize * 1.4,
                    height: logoSize * 1.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00D4FF).withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: logoSize * 1.15,
                  height: logoSize * 1.15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
                Container(
                  width: logoSize,
                  height: logoSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0D1521),
                    border: Border.all(
                      color: const Color(0xFF00D4FF).withValues(alpha: 0.6),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.remove_red_eye_outlined,
                    color: const Color(0xFF00D4FF),
                    size: logoSize * 0.45,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextSection(bool isSmall) {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _textOpacity,
          child: SlideTransition(
            position: _textSlide,
            child: Column(
              children: [
                Text(
                  'DMS',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: isSmall ? 38 : 48,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 60,
                  height: 1.5,
                  color: const Color(0xFF00D4FF).withValues(alpha: 0.6),
                ),
                const SizedBox(height: 12),
                Text(
                  'DRIVER MONITORING SYSTEM',
                  style: TextStyle(
                    fontSize: isSmall ? 9 : 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF00D4FF).withValues(alpha: 0.8),
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingSection(
    AsyncValue<AppAuthState> authAsync,
    bool isSmall,
  ) {
    return authAsync.when(
      // Still checking token → show spinner
      loading: () => Column(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: const Color(0xFF00D4FF),
              backgroundColor: const Color(0xFF00D4FF).withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Initializing system...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.4),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
      // Token check done → show checkmark
      // (GoRouter will redirect automatically — no code needed here)
      data: (_) => Column(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF00D4FF),
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            'System ready',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.4),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
      error: (e, _) => Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
          const SizedBox(height: 12),
          Text(
            'Failed to initialize',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionText(Size size) {
    return Positioned(
      bottom: size.height * 0.04,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _textController,
        builder: (context, _) => FadeTransition(
          opacity: _textOpacity,
          child: Text(
            'v1.0.0  •  Powered by AI',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.2),
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D4FF).withValues(alpha: 0.04)
      ..strokeWidth = 0.5;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
