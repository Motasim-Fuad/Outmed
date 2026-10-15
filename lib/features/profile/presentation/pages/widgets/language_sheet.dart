import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_event.dart';

class LanguageSheet extends StatelessWidget {
  const LanguageSheet({required this.auth, super.key});

  final AuthBloc auth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'choose_language'.tr,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('english'.tr),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                auth.add(const AuthLanguageChanged(Locale('en', 'US')));
                Navigator.pop(context);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('arabic'.tr),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                auth.add(const AuthLanguageChanged(Locale('ar', 'SA')));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
