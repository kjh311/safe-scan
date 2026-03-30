import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  static const Color _navyBlue = Color(0xFF1A237E);
  static const Color _lightCyan = Color(0xFF00E5FF);
  static const Color _whiteOutline = Color(0x80FFFFFF);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      if (_isSignUp) {
        await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (mounted) {
          _showMessage('Account created! Please check your email to verify.');
        }
      } else {
        await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
    } on AuthException catch (e) {
      if (mounted) _showMessage(e.message);
    } catch (e) {
      if (mounted) _showMessage('An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.white12,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navyBlue,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    _buildLogo(),
                    const SizedBox(height: 16),
                    Text(
                      'Verify Safe',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Smart Shopping Assistant',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 56),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 32),
                    _buildSignInButton(),
                    const SizedBox(height: 28),
                    _buildDivider(),
                    const SizedBox(height: 24),
                    _buildSocialButtons(),
                    const SizedBox(height: 28),
                    _buildToggleAuth(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      height: 80,
      width: 80,
      child: CustomPaint(painter: _LogoPainter(color: Colors.white)),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: 'Email',
        hintStyle: GoogleFonts.inter(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 16,
        ),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: Colors.white.withValues(alpha: 0.5),
          size: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _whiteOutline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: GoogleFonts.inter(color: Colors.redAccent, fontSize: 12),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Email is required';
        if (!RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(value.trim())) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      autocorrect: false,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle: GoogleFonts.inter(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 16,
        ),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: Colors.white.withValues(alpha: 0.5),
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.white.withValues(alpha: 0.5),
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _whiteOutline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: GoogleFonts.inter(color: Colors.redAccent, fontSize: 12),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Password is required';
        if (value.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightCyan,
          foregroundColor: _navyBlue,
          disabledBackgroundColor: _lightCyan.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(_navyBlue),
                ),
              )
            : Text(
                _isSignUp ? 'Create Account' : 'Sign In',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.45),
              letterSpacing: 0.3,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          icon: _GoogleIcon(color: Colors.white),
          label: 'Google',
          onTap: () => _showMessage('Google sign-in coming soon'),
        ),
        const SizedBox(width: 20),
        _buildSocialButton(
          icon: _AppleIcon(color: Colors.white),
          label: 'Apple',
          onTap: () => _showMessage('Apple sign-in coming soon'),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 22, height: 22, child: icon),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.9),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleAuth() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isSignUp ? 'Already have an account?' : "Don't have an account?",
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _isSignUp = !_isSignUp),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            _isSignUp ? 'Sign In' : 'Create an Account',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _lightCyan,
            ),
          ),
        ),
      ],
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  final Color color;
  const _GoogleIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GoogleIconPainter(color: color));
  }
}

class _GoogleIconPainter extends CustomPainter {
  final Color color;
  _GoogleIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 * s
      ..strokeCap = StrokeCap.round;

    // Google "G" - simplified geometric representation
    // Vertical line on the right (the "stem" of G)
    canvas.drawLine(Offset(12 * s, 5 * s), Offset(12 * s, 19 * s), paint);

    // Bottom curve
    final bottomArc = Path()
      ..addArc(
        Rect.fromCenter(
          center: Offset(12 * s, 12 * s),
          width: 14 * s,
          height: 14 * s,
        ),
        0.5,
        4.4,
      );
    canvas.drawPath(bottomArc, paint);

    // Top horizontal bar (Google's signature crossbar)
    final barPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(12 * s, 12 * s), Offset(19 * s, 12 * s), barPaint);

    // Small dot above top-right (the "eye" of G)
    canvas.drawCircle(
      Offset(17 * s, 6 * s),
      1.2 * s,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _GoogleIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _AppleIcon extends StatelessWidget {
  final Color color;
  const _AppleIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _AppleIconPainter(color: color));
  }
}

class _AppleIconPainter extends CustomPainter {
  final Color color;
  _AppleIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Apple logo - simplified filled path
    final path = Path()
      // Apple body
      ..moveTo(15.5 * s, 3.5 * s)
      ..cubicTo(14.5 * s, 2.0 * s, 12.5 * s, 2.0 * s, 12.5 * s, 2.0 * s)
      ..cubicTo(12.5 * s, 2.0 * s, 10.5 * s, 2.0 * s, 9.5 * s, 3.5 * s)
      ..cubicTo(7.5 * s, 3.5 * s, 5.5 * s, 5.5 * s, 5.5 * s, 9.5 * s)
      ..cubicTo(5.5 * s, 14.5 * s, 8.5 * s, 19.0 * s, 10.5 * s, 21.0 * s)
      ..cubicTo(11.5 * s, 22.0 * s, 12.5 * s, 22.0 * s, 13.5 * s, 21.0 * s)
      ..cubicTo(15.0 * s, 19.5 * s, 17.5 * s, 16.0 * s, 18.5 * s, 12.0 * s)
      ..cubicTo(16.5 * s, 12.5 * s, 14.5 * s, 11.0 * s, 14.5 * s, 11.0 * s)
      ..cubicTo(14.5 * s, 11.0 * s, 16.5 * s, 9.5 * s, 18.5 * s, 9.5 * s)
      ..cubicTo(18.5 * s, 5.5 * s, 17.5 * s, 3.5 * s, 15.5 * s, 3.5 * s)
      ..close();

    canvas.drawPath(path, paint);

    // Leaf/stem
    final stemPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stem = Path()
      ..moveTo(13.5 * s, 2.5 * s)
      ..cubicTo(13.5 * s, 2.5 * s, 14.5 * s, 1.0 * s, 16.5 * s, 1.5 * s)
      ..cubicTo(16.5 * s, 1.5 * s, 15.5 * s, 2.5 * s, 14.5 * s, 3.0 * s)
      ..close();
    canvas.drawPath(stem, stemPaint);
  }

  @override
  bool shouldRepaint(covariant _AppleIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _LogoPainter extends CustomPainter {
  final Color color;
  _LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double cx = w / 2;
    final double scale = w / 80;

    // Shopping cart body
    final cartPath = Path()
      ..moveTo(cx - 18 * scale, 20 * scale)
      ..lineTo(cx - 12 * scale, 20 * scale)
      ..lineTo(cx - 4 * scale, 42 * scale)
      ..lineTo(cx + 18 * scale, 42 * scale)
      ..lineTo(cx + 22 * scale, 24 * scale)
      ..lineTo(cx - 8 * scale, 24 * scale);

    canvas.drawPath(cartPath, paint);

    // Cart wheels
    canvas.drawCircle(Offset(cx, 50 * scale), 3.5 * scale, paint);
    canvas.drawCircle(Offset(cx + 14 * scale, 50 * scale), 3.5 * scale, paint);

    // Cart handle
    final handlePath = Path()
      ..moveTo(cx - 18 * scale, 20 * scale)
      ..lineTo(cx - 24 * scale, 12 * scale);

    canvas.drawPath(handlePath, paint);

    // Barcode lines inside cart area
    final barcodePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * scale
      ..strokeCap = StrokeCap.round;

    final barcodeLines = [
      cx - 6 * scale,
      cx - 2 * scale,
      cx + 2 * scale,
      cx + 6 * scale,
      cx + 10 * scale,
    ];

    for (final x in barcodeLines) {
      canvas.drawLine(
        Offset(x, 28 * scale),
        Offset(x, 38 * scale),
        barcodePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) =>
      oldDelegate.color != color;
}
