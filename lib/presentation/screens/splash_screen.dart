import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _textController;
  late Animation<double> _iconFadeIn;
  late Animation<double> _iconScale;
  late Animation<double> _titleFadeIn;
  late Animation<Offset> _titleSlideUp;
  late Animation<double> _taglineFadeIn;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Icon animation controller (600ms)
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Text animation controller (800ms total, staggered)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Icon fade and scale animations
    _iconFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeOutCubic),
    );

    _iconScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeOutCubic),
    );

    // Title animations (starts at 200ms)
    _titleFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.25, 0.75, curve: Curves.easeOutCirc),
      ),
    );

    _titleSlideUp = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.25, 0.75, curve: Curves.easeOutCirc),
      ),
    );

    // Tagline animation (starts at 500ms)
    _taglineFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.625, 1.0, curve: Curves.easeOutQuad),
      ),
    );
  }

  void _startAnimations() async {
    // Start icon animation immediately
    _iconController.forward();

    // Wait 200ms then start text animations
    await Future.delayed(const Duration(milliseconds: 200));
    _textController.forward();
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style for immersive experience
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Heart icon with fade and scale animation
            AnimatedBuilder(
              animation: _iconController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _iconFadeIn,
                  child: ScaleTransition(
                    scale: _iconScale,
                    child: child,
                  ),
                );
              },
              child: _buildHeartIcon(),
            ),

            const SizedBox(height: 40),

            // App title with fade and slide up animation
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _titleFadeIn,
                  child: SlideTransition(
                    position: _titleSlideUp,
                    child: child,
                  ),
                );
              },
              child: _buildTitle(),
            ),

            const SizedBox(height: 12),

            // Tagline with fade in animation
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _taglineFadeIn,
                  child: child,
                );
              },
              child: _buildTagline(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartIcon() {
    return Container(
      width: 72,
      height: 72,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: HeartIconPainter(),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Cardio Tracker',
      style: TextStyle(
        color: Color(0xFF1F2937),
        fontSize: 28,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.56,
        height: 1.2,
      ),
    );
  }

  Widget _buildTagline() {
    return const Text(
      'Your Heart Health Companion',
      style: TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.4,
      ),
    );
  }
}

class HeartIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final strokePath = Path();

    // Scale factor to fit the design in 72x72
    final scale = size.width / 72;

    // Heart shape
    path.moveTo(36 * scale, 48 * scale);
    path.cubicTo(
        30 * scale, 42 * scale, 24 * scale, 36 * scale, 24 * scale, 28 * scale);
    path.cubicTo(
        24 * scale, 24 * scale, 27 * scale, 20 * scale, 32 * scale, 20 * scale);
    path.cubicTo(
        34 * scale, 20 * scale, 35 * scale, 21 * scale, 36 * scale, 23 * scale);
    path.cubicTo(
        37 * scale, 21 * scale, 38 * scale, 20 * scale, 40 * scale, 20 * scale);
    path.cubicTo(
        45 * scale, 20 * scale, 48 * scale, 24 * scale, 48 * scale, 28 * scale);
    path.cubicTo(
        48 * scale, 36 * scale, 42 * scale, 42 * scale, 36 * scale, 48 * scale);
    path.close();

    // EKG pulse line
    strokePath.moveTo(48 * scale, 36 * scale);
    strokePath.lineTo(52 * scale, 36 * scale);
    strokePath.lineTo(54 * scale, 30 * scale);
    strokePath.lineTo(56 * scale, 42 * scale);
    strokePath.lineTo(58 * scale, 24 * scale);
    strokePath.lineTo(60 * scale, 36 * scale);
    strokePath.lineTo(64 * scale, 36 * scale);

    canvas.drawPath(path, paint);
    canvas.drawPath(strokePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
