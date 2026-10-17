import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';

class CartAddButton extends StatelessWidget {
  const CartAddButton({required this.count, required this.onTap, super.key});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inCart = count > 0;
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 14,
        backgroundColor: inCart ? AppColors.success : AppColors.primary,
        child: inCart
            ? Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              )
            : const Icon(Icons.add_rounded, size: 16, color: Colors.white),
      ),
    );
  }
}
