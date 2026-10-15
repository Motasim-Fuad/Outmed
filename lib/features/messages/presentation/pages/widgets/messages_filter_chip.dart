import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';

class MessagesFilterChip extends StatelessWidget {
  const MessagesFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.muted,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
