import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';

class PriceRow extends StatelessWidget {
  const PriceRow({
    required this.label,
    required this.value,
    this.emphasized = false,
    super.key,
  });

  final String label;
  final double value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: emphasized ? AppColors.ink : AppColors.muted,
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            '${'sar'.tr} ${value.toStringAsFixed(2)}',
            style: TextStyle(
              color: emphasized ? AppColors.primary : AppColors.ink,
              fontSize: emphasized ? 17 : 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
