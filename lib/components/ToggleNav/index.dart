import 'package:flutter/material.dart';

class ToggleNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onPressed;
  final ColorScheme colorTheme;
  const ToggleNav({
    super.key,
    required this.selectedIndex,
    required this.onPressed,
    required this.colorTheme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ToggleButtons(
        borderRadius: BorderRadius.circular(8),
        borderColor: colorTheme.surface,
        selectedColor: colorTheme.secondary,
        selectedBorderColor: colorTheme.surface,
        isSelected: [
          selectedIndex == 0,
          selectedIndex == 1,
          selectedIndex == 2,
        ],
        onPressed: onPressed,
        children: const [
          _ToggleButtonText(label: "For You"),
          _ToggleButtonText(label: "Trending"),
          _ToggleButtonText(label: "New"),
        ],
      ),
    );
  }
}

class _ToggleButtonText extends StatelessWidget {
  final String label;

  const _ToggleButtonText({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
      ),
    );
  }
}
