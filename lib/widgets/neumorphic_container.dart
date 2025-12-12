import 'package:flutter/material.dart';

/// A neumorphic container widget that creates a soft, pressed-in or raised-out appearance
/// Based on modern neumorphism design principles with soft shadows and smooth animations
class NeumorphicContainer extends StatelessWidget {
  /// The widget contained within the neumorphic container
  final Widget child;

  /// Whether the container appears pressed in or raised out
  final bool isPressed;

  /// The border radius of the container
  final double borderRadius;

  /// The padding around the child
  final EdgeInsetsGeometry padding;

  /// The margin around the container
  final EdgeInsetsGeometry margin;

  /// The width of the container
  final double? width;

  /// The height of the container
  final double? height;

  /// Custom color for the container (defaults to theme surface color)
  final Color? color;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.isPressed = false,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate neumorphic colors based on theme
    final baseColor = color ?? theme.colorScheme.surface;
    final shadowLight = isDark
        ? Colors.black.withValues(alpha: 0.5)
        : Colors.white.withValues(alpha: 0.7);
    final shadowDark = isDark
        ? Colors.black.withValues(alpha: 0.8)
        : Colors.black.withValues(alpha: 0.15);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isPressed
            ? [
                // Reversed shadows for pressed effect
                BoxShadow(
                  color: shadowLight,
                  blurRadius: 10,
                  offset: const Offset(4, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: shadowDark,
                  blurRadius: 10,
                  offset: const Offset(-4, -4),
                  spreadRadius: 0,
                ),
              ]
            : [
                // Outer shadow effect when not pressed
                BoxShadow(
                  color: shadowDark,
                  blurRadius: 10,
                  offset: const Offset(4, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: shadowLight,
                  blurRadius: 10,
                  offset: const Offset(-4, -4),
                  spreadRadius: 0,
                ),
              ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

/// A custom neumorphic decoration painter for more complex effects
class NeumorphicDecoration extends Decoration {
  final Color backgroundColor;
  final Color? lightShadowColor;
  final Color? darkShadowColor;
  final double borderRadius;
  final bool isPressed;
  final double blurRadius;
  final Offset shadowOffset;

  const NeumorphicDecoration({
    required this.backgroundColor,
    this.lightShadowColor,
    this.darkShadowColor,
    this.borderRadius = 20.0,
    this.isPressed = false,
    this.blurRadius = 10.0,
    this.shadowOffset = const Offset(4, 4),
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _NeumorphicPainter(
      backgroundColor: backgroundColor,
      lightShadowColor: lightShadowColor,
      darkShadowColor: darkShadowColor,
      borderRadius: borderRadius,
      isPressed: isPressed,
      blurRadius: blurRadius,
      shadowOffset: shadowOffset,
      onChanged: onChanged,
    );
  }
}

class _NeumorphicPainter extends BoxPainter {
  final Color backgroundColor;
  final Color? lightShadowColor;
  final Color? darkShadowColor;
  final double borderRadius;
  final bool isPressed;
  final double blurRadius;
  final Offset shadowOffset;

  _NeumorphicPainter({
    required this.backgroundColor,
    this.lightShadowColor,
    this.darkShadowColor,
    required this.borderRadius,
    required this.isPressed,
    required this.blurRadius,
    required this.shadowOffset,
    VoidCallback? onChanged,
  }) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect bounds = offset & configuration.size!;
    final RRect outer =
        RRect.fromRectAndRadius(bounds, Radius.circular(borderRadius));

    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(outer, backgroundPaint);

    // Draw shadows
    if (!isPressed) {
      // Outer shadows
      _drawShadow(
        canvas,
        bounds,
        borderRadius,
        darkShadowColor ?? Colors.black.withValues(alpha: 0.15),
        shadowOffset,
        blurRadius,
      );
      _drawShadow(
        canvas,
        bounds,
        borderRadius,
        lightShadowColor ?? Colors.white.withValues(alpha: 0.7),
        -shadowOffset,
        blurRadius,
      );
    }
  }

  void _drawShadow(
    Canvas canvas,
    Rect bounds,
    double borderRadius,
    Color color,
    Offset offset,
    double blurRadius,
  ) {
    final shadowPaint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);

    final shadowRect = bounds.shift(offset);
    final shadowRRect =
        RRect.fromRectAndRadius(shadowRect, Radius.circular(borderRadius));
    canvas.drawRRect(shadowRRect, shadowPaint);
  }
}
