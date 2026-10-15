import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/features/notifications/presentation/widgets/notification_bell.dart';
import 'package:outmed/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:outmed/features/profile/presentation/bloc/profile_state.dart';

class BuyerGreeting extends StatelessWidget {
  const BuyerGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primarySoft,
          child: Icon(Icons.person_rounded, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: BlocSelector<ProfileBloc, ProfileState, String>(
            selector: (state) => state.profile.displayName,
            builder: (context, name) => Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: name.isEmpty
                        ? 'good_evening'.tr
                        : '${'good_evening'.tr}, ',
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (name.isNotEmpty)
                    TextSpan(
                      text: '$name!',
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
      ],
    );
  }
}
