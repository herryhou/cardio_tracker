import 'package:flutter/material.dart';

/// A neumorphic button widget with pressed state animations
/// Provides a soft, tactile feel with inner/outer shadow effects
class NeumorphicButton extends StatefulWidget {
  /// The callback when the button is pressed
  final VoidCallback? onPressed;

  /// The widget contained within the button
  final Widget child;

  /// The width of the button
  final double? width;

  /// The height of the button
  final double? height;

  /// The border radius of the button
  final double borderRadius;

  /// The padding around the child
  final EdgeInsetsGeometry padding;

  /// Whether the button is disabled
  final bool disabled;

  /// Custom color for the button (defaults to theme surface color)
  final Color? color;

  const NeumorphicButton({
    super.key,
    required this.child,
    this.onPressed,
    this.width,
    this.height,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.disabled = false,
    this.color,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.disabled && widget.onPressed != null) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.disabled && widget.onPressed != null) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
      widget.onPressed?.call();
    }
  }

  void _handleTapCancel() {
    if (!widget.disabled && widget.onPressed != null) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          widget.disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: widget.disabled ? 0.5 : 1.0,
                child: _NeumorphicButtonContainer(
                  isPressed: _isPressed,
                  disabled: widget.disabled,
                  width: widget.width,
                  height: widget.height,
                  borderRadius: widget.borderRadius,
                  padding: widget.padding,
                  color: widget.color,
                  child: widget.child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Internal container widget for the neumorphic button appearance
class _NeumorphicButtonContainer extends StatelessWidget {
  final Widget child;
  final bool isPressed;
  final bool disabled;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const _NeumorphicButtonContainer({
    required this.child,
    required this.isPressed,
    required this.disabled,
    this.width,
    this.height,
    required this.borderRadius,
    required this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate neumorphic colors based on theme
    final baseColor = color ?? theme.colorScheme.surface;
    final shadowLight = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.white.withValues(alpha: 0.8);
    final shadowDark = isDark
        ? Colors.black.withValues(alpha: 0.6)
        : Colors.black.withValues(alpha: 0.2);

    // Ensure minimum touch target size of 48dp for accessibility
    final effectiveWidth = width ?? 48.0;
    final effectiveHeight = height ?? 48.0;

    return Container(
      width: effectiveWidth,
      height: effectiveHeight,
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isPressed || disabled
            ? [
                // Reversed shadows for pressed effect
                BoxShadow(
                  color: shadowLight,
                  blurRadius: 10,
                  offset: const Offset(2, 2),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: shadowDark,
                  blurRadius: 10,
                  offset: const Offset(-2, -2),
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
      child: Center(
        child: DefaultTextStyle(
          style: DefaultTextStyle.of(context).style.copyWith(
                color: disabled
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                    : theme.colorScheme.onSurface,
              ),
          child: child,
        ),
      ),
    );
  }
}
