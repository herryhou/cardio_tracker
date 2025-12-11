import 'package:flutter/material.dart';

/// A neumorphic slider widget with soft shadows and smooth animations
/// Perfect for theme toggles and other range selection UI elements
class NeumorphicSlider extends StatefulWidget {
  /// The current value of the slider
  final double value;

  /// Called when the user changes the slider value
  final ValueChanged<double>? onChanged;

  /// Called when the user starts changing the slider value
  final ValueChanged<double>? onChangeStart;

  /// Called when the user stops changing the slider value
  final ValueChanged<double>? onChangeEnd;

  /// The minimum value the slider can have
  final double min;

  /// The maximum value the slider can have
  final double max;

  /// The number of discrete divisions the slider has
  final int? divisions;

  /// The height of the slider track
  final double trackHeight;

  /// The size of the slider thumb
  final double thumbSize;

  /// The border radius of the track and thumb
  final double borderRadius;

  /// Custom color for the active portion of the track
  final Color? activeColor;

  /// Custom color for the inactive portion of the track
  final Color? inactiveColor;

  /// Custom color for the thumb
  final Color? thumbColor;

  const NeumorphicSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.trackHeight = 8.0,
    this.thumbSize = 24.0,
    this.borderRadius = 20.0,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
  });

  @override
  State<NeumorphicSlider> createState() => _NeumorphicSliderState();
}

class _NeumorphicSliderState extends State<NeumorphicSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _thumbScaleAnimation;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _thumbScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
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

  void _handlePanStart(DragStartDetails details) {
    if (widget.onChanged != null) {
      setState(() {
        _isDragging = true;
      });
      _animationController.forward();
      widget.onChangeStart?.call(widget.value);
    }
  }

  void _handlePanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (widget.onChanged != null) {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final Offset localPosition = box.globalToLocal(details.globalPosition);
      final double newValue = (localPosition.dx / constraints.maxWidth)
          .clamp(0.0, 1.0)
          .mapRange(0.0, 1.0, widget.min, widget.max);

      if (widget.divisions != null) {
        final double divisionValue =
            (widget.max - widget.min) / widget.divisions!;
        final double roundedValue = (newValue - widget.min) / divisionValue;
        final double snappedValue =
            (roundedValue.round() * divisionValue) + widget.min;
        widget.onChanged!(snappedValue.clamp(widget.min, widget.max));
      } else {
        widget.onChanged!(newValue);
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (widget.onChanged != null) {
      setState(() {
        _isDragging = true;
      });
      _animationController.reverse();
      widget.onChangeEnd?.call(widget.value);
    }
  }

  void _handleTapUp(TapUpDetails details, BoxConstraints constraints) {
    if (widget.onChanged != null) {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final Offset localPosition = box.globalToLocal(details.globalPosition);
      final double newValue = (localPosition.dx / constraints.maxWidth)
          .clamp(0.0, 1.0)
          .mapRange(0.0, 1.0, widget.min, widget.max);

      if (widget.divisions != null) {
        final double divisionValue =
            (widget.max - widget.min) / widget.divisions!;
        final double roundedValue = (newValue - widget.min) / divisionValue;
        final double snappedValue =
            (roundedValue.round() * divisionValue) + widget.min;
        widget.onChanged!(snappedValue.clamp(widget.min, widget.max));
      } else {
        widget.onChanged!(newValue);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate neumorphic colors
    final activeTrackColor = widget.activeColor ?? theme.colorScheme.primary;
    final inactiveTrackColor = widget.inactiveColor ??
        theme.colorScheme.surfaceVariant.withOpacity(0.5);
    final thumbColor = widget.thumbColor ?? theme.colorScheme.surface;

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final thumbPosition = (widget.value - widget.min) /
            (widget.max - widget.min) *
            trackWidth;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _animationController.forward(),
          onTapUp: (details) => _handleTapUp(details, constraints),
          onTapCancel: () => _animationController.reverse(),
          onHorizontalDragStart: _handlePanStart,
          onHorizontalDragUpdate: (details) =>
              _handlePanUpdate(details, constraints),
          onHorizontalDragEnd: _handlePanEnd,
          child: SizedBox(
            width: trackWidth,
            height: widget.thumbSize + 16, // Extra space for thumb
            child: Stack(
              children: [
                // Inactive track
                Positioned(
                  top: (widget.thumbSize - widget.trackHeight) / 2,
                  left: 0,
                  right: 0,
                  height: widget.trackHeight,
                  child: _NeumorphicTrack(
                    color: inactiveTrackColor,
                    height: widget.trackHeight,
                    borderRadius: widget.borderRadius,
                    isPressed: false,
                  ),
                ),
                // Active track
                Positioned(
                  top: (widget.thumbSize - widget.trackHeight) / 2,
                  left: 0,
                  width: thumbPosition,
                  height: widget.trackHeight,
                  child: _NeumorphicTrack(
                    color: activeTrackColor,
                    height: widget.trackHeight,
                    borderRadius: widget.borderRadius,
                    isPressed: _isDragging,
                  ),
                ),
                // Thumb
                Positioned(
                  left: thumbPosition - widget.thumbSize / 2,
                  top: 8,
                  width: widget.thumbSize,
                  height: widget.thumbSize,
                  child: AnimatedBuilder(
                    animation: _thumbScaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _thumbScaleAnimation.value,
                        child: _NeumorphicThumb(
                          color: thumbColor,
                          size: widget.thumbSize,
                          isPressed: _isDragging,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Neumorphic track widget
class _NeumorphicTrack extends StatelessWidget {
  final Color color;
  final double height;
  final double borderRadius;
  final bool isPressed;

  const _NeumorphicTrack({
    required this.color,
    required this.height,
    required this.borderRadius,
    required this.isPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final shadowLight =
        isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.6);
    final shadowDark =
        isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.1);

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isPressed
            ? [
                // Reversed shadows for pressed effect
                BoxShadow(
                  color: shadowLight,
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: shadowDark,
                  blurRadius: 4,
                  offset: const Offset(-2, -2),
                  spreadRadius: 0,
                ),
              ]
            : [
                // Outer shadows
                BoxShadow(
                  color: shadowDark,
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: shadowLight,
                  blurRadius: 4,
                  offset: const Offset(-2, -2),
                  spreadRadius: 0,
                ),
              ],
      ),
    );
  }
}

/// Neumorphic thumb widget
class _NeumorphicThumb extends StatelessWidget {
  final Color color;
  final double size;
  final bool isPressed;

  const _NeumorphicThumb({
    required this.color,
    required this.size,
    required this.isPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final shadowLight =
        isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.8);
    final shadowDark =
        isDark ? Colors.black.withOpacity(0.6) : Colors.black.withOpacity(0.2);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: isPressed
            ? [
                // Reversed shadows when pressed
                BoxShadow(
                  color: shadowLight,
                  blurRadius: 6,
                  offset: const Offset(3, 3),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: shadowDark,
                  blurRadius: 6,
                  offset: const Offset(-3, -3),
                  spreadRadius: 0,
                ),
              ]
            : [
                // Outer shadow when not pressed
                BoxShadow(
                  color: shadowDark,
                  blurRadius: 6,
                  offset: const Offset(3, 3),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: shadowLight,
                  blurRadius: 6,
                  offset: const Offset(-3, -3),
                  spreadRadius: 0,
                ),
              ],
      ),
    );
  }
}

/// Extension for mapping ranges
extension DoubleExtension on double {
  double mapRange(double fromMin, double fromMax, double toMin, double toMax) {
    final fromRange = fromMax - fromMin;
    final toRange = toMax - toMin;
    final normalized = (this - fromMin) / fromRange;
    return toMin + normalized * toRange;
  }
}
