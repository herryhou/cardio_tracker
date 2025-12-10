import 'package:flutter/material.dart';

/// A specialized neumorphic slider for theme selection
/// Shows 3 options: System, Light, and Dark themes
class NeumorphicSliderThemeToggle extends StatefulWidget {
  /// The current value (0 = System, 1 = Light, 2 = Dark)
  final double value;

  /// Callback when the value changes
  final ValueChanged<double>? onChanged;

  const NeumorphicSliderThemeToggle({
    super.key,
    required this.value,
    this.onChanged,
  });

  @override
  State<NeumorphicSliderThemeToggle> createState() => _NeumorphicSliderThemeToggleState();
}

class _NeumorphicSliderThemeToggleState extends State<NeumorphicSliderThemeToggle> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.7),
            blurRadius: 8,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            // System theme option
            Expanded(
              child: _ThemeOption(
                isSelected: widget.value == 0,
                icon: Icons.brightness_auto,
                label: 'System',
                onTap: () => widget.onChanged?.call(0),
              ),
            ),
            // Light theme option
            Expanded(
              child: _ThemeOption(
                isSelected: widget.value == 1,
                icon: Icons.light_mode,
                label: 'Light',
                onTap: () => widget.onChanged?.call(1),
              ),
            ),
            // Dark theme option
            Expanded(
              child: _ThemeOption(
                isSelected: widget.value == 2,
                icon: Icons.dark_mode,
                label: 'Dark',
                onTap: () => widget.onChanged?.call(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatefulWidget {
  final bool isSelected;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ThemeOption({
    required this.isSelected,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  State<_ThemeOption> createState() => _ThemeOptionState();
}

class _ThemeOptionState extends State<_ThemeOption> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isSelected) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_ThemeOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: 52,
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(26),
                boxShadow: widget.isSelected ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      size: 20,
                      color: widget.isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: widget.isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}