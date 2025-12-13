import 'package:flutter/material.dart';

class AutoScrollToggle extends StatefulWidget {
  const AutoScrollToggle({
    super.key,
    required this.isEnabled,
    required this.onChanged,
  });

  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  @override
  State<AutoScrollToggle> createState() => _AutoScrollToggleState();
}

class _AutoScrollToggleState extends State<AutoScrollToggle> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle,
            size: 20,
            color: widget.isEnabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'Auto-scroll',
            style: TextStyle(
              color: widget.isEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: widget.isEnabled,
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}