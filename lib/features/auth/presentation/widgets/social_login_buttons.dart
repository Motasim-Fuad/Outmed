import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/auth/social_auth_service.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_event.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_state.dart';
import 'package:outmed/shared/widgets/custom_button.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final social = SocialAuthService();
    if (!social.googleEnabled && !social.appleEnabled) {
      return const SizedBox.shrink();
    }
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          !previous.pendingOnboarding &&
          current.pendingOnboarding &&
          current.socialSession,
      listener: (context, state) => AppNav.go(AppRoutes.profileSelection),
      child: BlocSelector<AuthBloc, AuthState, (bool, String)>(
        selector: (state) =>
            (state.status == LoadStatus.loading, state.socialProvider),
        builder: (context, data) {
          final (busy, provider) = data;
          void start(String name) =>
              context.read<AuthBloc>().add(AuthSocialRequested(name));
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or_continue_with'.tr,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 14),
              if (social.googleEnabled)
                CustomButton(
                  label: 'continue_with_google'.tr,
                  icon: Icons.g_mobiledata_rounded,
                  outlined: true,
                  isLoading: provider == 'google',
                  onPressed: busy ? null : () => start('google'),
                ),
              if (social.googleEnabled && social.appleEnabled)
                const SizedBox(height: 10),
              if (social.appleEnabled)
                CustomButton(
                  label: 'continue_with_apple'.tr,
                  icon: Icons.apple_rounded,
                  outlined: true,
                  isLoading: provider == 'apple',
                  onPressed: busy ? null : () => start('apple'),
                ),
            ],
          );
        },
      ),
    );
  }
}
