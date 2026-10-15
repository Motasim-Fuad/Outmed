import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';

class SupplierTrustChip extends StatelessWidget {
  const SupplierTrustChip({required this.icon, required this.label, super.key});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(label),
      backgroundColor: AppColors.primarySoft,
      side: BorderSide.none,
    );
  }
}
