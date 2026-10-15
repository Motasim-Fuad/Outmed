import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_event.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_state.dart';
import 'package:outmed/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:outmed/features/notifications/presentation/bloc/notification_state.dart';
import 'package:outmed/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:outmed/features/profile/presentation/bloc/profile_event.dart';
import 'package:outmed/features/profile/presentation/pages/widgets/language_sheet.dart';
import 'package:outmed/features/profile/presentation/pages/widgets/profile_header.dart';
import 'package:outmed/features/profile/presentation/pages/widgets/profile_item.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({required this.supplier, super.key});

  final bool supplier;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async =>
              context.read<ProfileBloc>().add(const ProfileStarted()),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
            children: [
              Text(
                'my_profile'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              ProfileHeader(supplier: supplier),
              const SizedBox(height: 20),
              ProfileItem(
                icon: Icons.person_outline_rounded,
                label: 'edit_profile'.tr,
                onTap: () => AppNav.push(AppRoutes.editProfile),
              ),
              ProfileItem(
                icon: Icons.business_outlined,
                label: 'company_profile'.tr,
                onTap: () => AppNav.push(AppRoutes.editProfile),
              ),
              ProfileItem(
                icon: Icons.shield_outlined,
                label: 'security'.tr,
                onTap: () => AppNav.push(AppRoutes.security),
              ),
              if (!supplier)
                ProfileItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'my_orders'.tr,
                  onTap: () => AppNav.push(AppRoutes.buyerOrders),
                ),
              ProfileItem(
                icon: Icons.location_on_outlined,
                label: 'addresses'.tr,
                onTap: () =>
                    AppNav.push('${AppRoutes.editProfile}?section=address'),
              ),
              ProfileItem(
                icon: Icons.language_rounded,
                label: 'language'.tr,
                onTap: () => unawaited(
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (_) =>
                        LanguageSheet(auth: context.read<AuthBloc>()),
                  ),
                ),
              ),
              BlocSelector<NotificationBloc, NotificationState, int>(
                selector: (state) => state.unread,
                builder: (context, unread) => ProfileItem(
                  icon: Icons.notifications_none_rounded,
                  label: 'notifications'.tr,
                  onTap: () => AppNav.push(AppRoutes.notifications),
                  trailing: unread == 0
                      ? null
                      : CircleAvatar(
                          radius: 11,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                ),
              ),
              ProfileItem(
                icon: Icons.help_outline_rounded,
                label: 'help_support'.tr,
                onTap: () => AppNav.push(AppRoutes.helpSupport),
              ),
              ProfileItem(
                icon: Icons.description_outlined,
                label: 'terms_conditions'.tr,
                onTap: () =>
                    AppNav.push('${AppRoutes.legal}?type=TERMS_AND_CONDITIONS'),
              ),
              const SizedBox(height: 12),
              BlocSelector<AuthBloc, AuthState, bool>(
                selector: (state) => state.authenticated,
                builder: (context, authenticated) => ProfileItem(
                  icon: Icons.logout_rounded,
                  label: 'logout'.tr,
                  danger: true,
                  onTap: authenticated
                      ? () => context.read<AuthBloc>().add(
                          const AuthLogoutRequested(),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
