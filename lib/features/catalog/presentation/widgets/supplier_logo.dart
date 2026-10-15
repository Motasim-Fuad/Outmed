import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/shared/widgets/app_asset_image.dart';

class SupplierLogo extends StatelessWidget {
  const SupplierLogo({
    required this.logo,
    required this.name,
    this.size = 64,
    super.key,
  });

  final String logo;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (logo.isNotEmpty) {
      return SizedBox(width: size, height: size, child: AppAssetImage(logo));
    }
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}
