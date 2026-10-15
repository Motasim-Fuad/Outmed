import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';

class ProfileItem extends StatelessWidget {
  const ProfileItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.danger = false,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool danger;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          leading: Icon(
            icon,
            color: danger ? AppColors.danger : AppColors.primary,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: danger ? AppColors.danger : AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          trailing:
              trailing ?? const Icon(Icons.chevron_right_rounded, size: 20),
        ),
      ),
    );
  }
}
