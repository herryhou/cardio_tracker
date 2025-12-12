import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'neumorphic_container.dart';

/// A neumorphic tile widget that provides a soft, pressed-in appearance
/// Perfect for list items and settings options with proper touch targets
class NeumorphicTile extends StatefulWidget {
  /// The leading icon widget
  final Widget? leading;

  /// The title widget
  final Widget title;

  /// The subtitle widget (optional)
  final Widget? subtitle;

  /// The trailing widget (optional)
  final Widget? trailing;

  /// Callback when the tile is tapped
  final VoidCallback? onTap;

  /// Whether the tile is enabled
  final bool enabled;

  /// The padding around the tile content
  final EdgeInsetsGeometry padding;

  /// The margin around the tile
  final EdgeInsetsGeometry margin;

  /// The border radius of the tile
  final double borderRadius;

  /// Custom color for the tile
  final Color? color;

  /// Minimum height for the tile (ensures 48dp touch target)
  final double? minHeight;

  const NeumorphicTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 4),
    this.borderRadius = 12.0,
    this.color,
    this.minHeight,
  });

  @override
  State<NeumorphicTile> createState() => _NeumorphicTileState();
}

class _NeumorphicTileState extends State<NeumorphicTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
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
    if (widget.enabled && widget.onTap != null) {
      HapticFeedback.lightImpact();
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enabled && widget.onTap != null) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
      widget.onTap?.call();
    }
  }

  void _handleTapCancel() {
    if (widget.enabled && widget.onTap != null) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Ensure minimum touch target size of 48dp for accessibility
    final effectiveMinHeight = widget.minHeight ?? 48.0;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: widget.enabled ? 1.0 : 0.5,
              child: NeumorphicContainer(
                isPressed: _isPressed,
                borderRadius: widget.borderRadius,
                margin: widget.margin,
                padding: EdgeInsets.zero,
                color: widget.color,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: effectiveMinHeight,
                  ),
                  child: Padding(
                    padding: widget.padding,
                    child: Row(
                      children: [
                        if (widget.leading != null) ...[
                          widget.leading!,
                          const SizedBox(width: 16),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DefaultTextStyle(
                                style: theme.textTheme.titleMedium!.copyWith(
                                  color: widget.enabled
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                                ),
                                child: widget.title,
                              ),
                              if (widget.subtitle != null) ...[
                                const SizedBox(height: 4),
                                DefaultTextStyle(
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    color: widget.enabled
                                        ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                                        : theme.colorScheme.onSurface.withValues(alpha: 0.28),
                                  ),
                                  child: widget.subtitle!,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (widget.trailing != null) ...[
                          const SizedBox(width: 16),
                          widget.trailing!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}