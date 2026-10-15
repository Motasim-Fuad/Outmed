import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';

class OrderStatusStep extends StatelessWidget {
  const OrderStatusStep({
    required this.label,
    required this.complete,
    required this.last,
    super.key,
  });

  final String label;
  final bool complete;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: complete
                      ? AppColors.primary
                      : AppColors.border,
                  child: complete
                      ? const Icon(Icons.check, size: 13, color: Colors.white)
                      : null,
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: complete ? AppColors.primary : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 10, bottom: 24),
              child: Text(
                label,
                style: TextStyle(
                  color: complete ? AppColors.ink : AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
