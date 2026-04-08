import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────
  // HOW AUTH WORKS NOW WITH SUPABASE:
  //
  // 1. User taps Sign In
  // 2. _handleLogin() calls authActionsProvider.login()
  // 3. AuthRepository calls supabase.auth.signInWithPassword()
  // 4. Supabase verifies credentials on their server
  // 5. On success → Supabase fires signedIn event on stream
  // 6. authProvider (StreamProvider) picks up the event
  // 7. _RouterNotifier detects change → GoRouter redirects
  // 8. User lands on Dashboard
  //
  // On error → authActionsProvider goes to error state
  // ref.listen detects error → shows snackbar
  // ─────────────────────────────────────────────────────
  void _setupListeners() {
    ref.listen<AsyncValue<void>>(authActionsProvider, (previous, next) {
      // On error → show snackbar
      if (next is AsyncError) {
        final msg = next.error
            .toString()
            .replaceAll('AuthException: ', '')
            .replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: const Color(0xFFE24B4A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
      // Navigation is handled by GoRouter automatically —
      // no context.go() needed here
    });
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(authActionsProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    _setupListeners();

    // Watch actions provider for loading state only
    final isLoading = ref.watch(authActionsProvider).isLoading;
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;
    final hPad = size.width * 0.06;

    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      body: Stack(
        children: [
          CustomPaint(size: size, painter: _GridPainter()),
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00D4FF).withValues(alpha: 0.04),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.08),
                        _buildHeader(isSmall),
                        SizedBox(height: size.height * 0.06),
                        _buildLabel('EMAIL ADDRESS'),
                        const SizedBox(height: 8),
                        _buildEmailField(isSmall),
                        SizedBox(height: size.height * 0.025),
                        _buildLabel('PASSWORD'),
                        const SizedBox(height: 8),
                        _buildPasswordField(isSmall),
                        const SizedBox(height: 12),
                        _buildRememberRow(isSmall),
                        SizedBox(height: size.height * 0.05),
                        _buildLoginButton(isLoading, isSmall),
                        SizedBox(height: size.height * 0.03),
                        _buildDivider(),
                        SizedBox(height: size.height * 0.03),
                        _buildRegisterLink(isSmall),
                        SizedBox(height: size.height * 0.04),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isSmall) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF00D4FF).withValues(alpha: 0.5),
            width: 1.5,
          ),
          color: const Color(0xFF0D1521),
        ),
        child: const Icon(
          Icons.remove_red_eye_outlined,
          color: Color(0xFF00D4FF),
          size: 20,
        ),
      ),
      const SizedBox(height: 24),
      Text(
        'Welcome\nback.',
        style: TextStyle(
          fontSize: isSmall ? 34 : 42,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.1,
          letterSpacing: -0.5,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        'Sign in to monitor your driver safety system.',
        style: TextStyle(
          fontSize: isSmall ? 13 : 14,
          color: Colors.white.withValues(alpha: 0.4),
          height: 1.5,
        ),
      ),
    ],
  );

  Widget _buildLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF00D4FF).withValues(alpha: 0.7),
      letterSpacing: 2,
    ),
  );

  Widget _buildEmailField(bool isSmall) => TextFormField(
    controller: _emailController,
    keyboardType: TextInputType.emailAddress,
    style: TextStyle(color: Colors.white, fontSize: isSmall ? 14 : 15),
    decoration: _inputDecoration(
      hint: 'driver@example.com',
      icon: Icons.alternate_email,
    ),
    validator: (val) {
      if (val == null || val.trim().isEmpty) return 'Email is required';
      if (!val.contains('@')) return 'Enter a valid email';
      return null;
    },
  );

  Widget _buildPasswordField(bool isSmall) => TextFormField(
    controller: _passwordController,
    obscureText: _obscurePassword,
    style: TextStyle(color: Colors.white, fontSize: isSmall ? 14 : 15),
    decoration: _inputDecoration(hint: '••••••••', icon: Icons.lock_outline)
        .copyWith(
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.white.withValues(alpha: 0.3),
              size: 20,
            ),
          ),
        ),
    validator: (val) {
      if (val == null || val.isEmpty) return 'Password is required';
      if (val.length < 6) return 'Minimum 6 characters';
      return null;
    },
  );

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: Colors.white.withValues(alpha: 0.2),
      fontSize: 14,
    ),
    prefixIcon: Icon(
      icon,
      color: Colors.white.withValues(alpha: 0.25),
      size: 18,
    ),
    filled: true,
    fillColor: const Color(0xFF0D1521),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Colors.white.withValues(alpha: 0.08),
        width: 1,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Colors.white.withValues(alpha: 0.08),
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF00D4FF), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1.5),
    ),
    errorStyle: const TextStyle(color: Color(0xFFE24B4A), fontSize: 11),
  );

  Widget _buildRememberRow(bool isSmall) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      GestureDetector(
        onTap: () => setState(() => _rememberMe = !_rememberMe),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _rememberMe
                      ? const Color(0xFF00D4FF)
                      : Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                color: _rememberMe
                    ? const Color(0xFF00D4FF).withValues(alpha: 0.15)
                    : Colors.transparent,
              ),
              child: _rememberMe
                  ? const Icon(Icons.check, size: 12, color: Color(0xFF00D4FF))
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              'Remember me',
              style: TextStyle(
                fontSize: isSmall ? 12 : 13,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
      GestureDetector(
        onTap: () {},
        child: Text(
          'Forgot password?',
          style: TextStyle(
            fontSize: isSmall ? 12 : 13,
            color: const Color(0xFF00D4FF).withValues(alpha: 0.8),
          ),
        ),
      ),
    ],
  );

  Widget _buildLoginButton(bool isLoading, bool isSmall) => SizedBox(
    width: double.infinity,
    height: 52,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isLoading
            ? const Color(0xFF00D4FF).withValues(alpha: 0.3)
            : const Color(0xFF00D4FF).withValues(alpha: 0.15),
        border: Border.all(
          color: const Color(
            0xFF00D4FF,
          ).withValues(alpha: isLoading ? 0.3 : 0.6),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isLoading ? null : _handleLogin,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF00D4FF),
                    ),
                  )
                : Text(
                    'SIGN IN',
                    style: TextStyle(
                      fontSize: isSmall ? 13 : 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00D4FF),
                      letterSpacing: 3,
                    ),
                  ),
          ),
        ),
      ),
    ),
  );

  Widget _buildDivider() => Row(
    children: [
      Expanded(
        child: Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'OR',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.2),
            letterSpacing: 2,
          ),
        ),
      ),
      Expanded(
        child: Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
    ],
  );

  Widget _buildRegisterLink(bool isSmall) => Center(
    child: GestureDetector(
      onTap: () => context.push('/register'),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: isSmall ? 13 : 14),
          children: [
            TextSpan(
              text: "Don't have an account? ",
              style: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
            ),
            const TextSpan(
              text: 'Create one',
              style: TextStyle(
                color: Color(0xFF00D4FF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D4FF).withValues(alpha: 0.03)
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
