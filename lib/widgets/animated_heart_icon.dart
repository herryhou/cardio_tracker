import 'package:flutter/material.dart';
import 'app_icon.dart';

/// An animated heart icon with pulse effect
/// Provides smooth scaling animation to simulate heartbeat
class AnimatedHeartIcon extends StatefulWidget {
  /// The size of the heart icon
  final double size;

  /// The color of the heart
  final Color color;

  /// Whether to animate the heart
  final bool animate;

  /// Animation duration
  final Duration duration;

  /// Custom animation curve
  final Curve curve;

  /// Whether to use the custom HeartIcon or Material icon
  final bool useCustomHeart;

  const AnimatedHeartIcon({
    super.key,
    this.size = 24.0,
    this.color = Colors.red,
    this.animate = true,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeInOut,
    this.useCustomHeart = true,
  });

  @override
  State<AnimatedHeartIcon> createState() => _AnimatedHeartIconState();
}

class _AnimatedHeartIconState extends State<AnimatedHeartIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Create scale animation for heartbeat effect
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Create subtle opacity animation
    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start animation if enabled
    if (widget.animate) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(AnimatedHeartIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle animation state changes
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _controller.repeat(reverse: true);
  }

  void _stopAnimation() {
    _controller.stop();
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Heart rate indicator',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.animate ? _scaleAnimation.value : 1.0,
            child: Opacity(
              opacity: widget.animate ? _opacityAnimation.value : 1.0,
              child: widget.useCustomHeart
                  ? HeartIcon(
                      size: widget.size,
                      color: widget.color,
                      filled: true,
                    )
                  : Icon(
                      Icons.favorite,
                      size: widget.size,
                      color: widget.color,
                    ),
            ),
          );
        },
      ),
    );
  }
}

/// A pulsating heart icon container with neumorphic styling
/// Can be used for pulse indicators or decorative elements
class PulsatingHeartContainer extends StatefulWidget {
  /// Child widget to display inside the container
  final Widget child;

  /// Whether to show the pulsating heart animation
  final bool showPulse;

  /// The size of the container
  final double size;

  /// Background color of the container
  final Color? backgroundColor;

  /// Pulse color
  final Color pulseColor;

  /// Border radius of the container
  final double borderRadius;

  const PulsatingHeartContainer({
    super.key,
    required this.child,
    this.showPulse = true,
    this.size = 80.0,
    this.backgroundColor,
    this.pulseColor = Colors.red,
    this.borderRadius = 20.0,
  });

  @override
  State<PulsatingHeartContainer> createState() => _PulsatingHeartContainerState();
}

class _PulsatingHeartContainerState extends State<PulsatingHeartContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    if (widget.showPulse) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(PulsatingHeartContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showPulse != oldWidget.showPulse) {
      if (widget.showPulse) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = widget.backgroundColor ?? theme.colorScheme.surface;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse effect rings
          if (widget.showPulse) ...[
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.pulseColor.withOpacity(
                        (1.0 - _pulseAnimation.value) * 0.5,
                      ),
                      width: 2,
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.5 + (_pulseAnimation.value * 0.5),
                  child: Container(
                    width: widget.size * 0.8,
                    height: widget.size * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.pulseColor.withOpacity(
                          (1.0 - _pulseAnimation.value) * 0.3,
                        ),
                        width: 1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],

          // Main container
          Container(
            width: widget.size * 0.7,
            height: widget.size * 0.7,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(child: widget.child),
          ),
        ],
      ),
    );
  }
}