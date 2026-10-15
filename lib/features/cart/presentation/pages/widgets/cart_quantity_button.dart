import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';

class CartQuantityButton extends StatelessWidget {
  const CartQuantityButton({
    required this.icon,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 15, color: AppColors.primary),
      ),
    );
  }
}
