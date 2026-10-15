import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/notifications/presentation/widgets/notification_bell.dart';
import 'package:outmed/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:outmed/features/profile/presentation/bloc/profile_state.dart';

class SupplierGreeting extends StatelessWidget {
  const SupplierGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primarySoft,
          child: Icon(Icons.local_hospital_rounded, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: BlocSelector<ProfileBloc, ProfileState, String>(
            selector: (state) => state.profile.organization.isNotEmpty
                ? state.profile.organization
                : state.profile.displayName,
            builder: (context, name) => Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${'good_evening'.tr} ',
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: name,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const NotificationBell(),
        IconButton(
          onPressed: () => AppNav.push('${AppRoutes.messages}?back=1'),
          icon: const Icon(Icons.chat_bubble_outline_rounded),
        ),
      ],
    );
  }
}
