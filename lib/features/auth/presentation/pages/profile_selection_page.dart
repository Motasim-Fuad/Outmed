import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_assets.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/auth/domain/user_role.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_event.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_state.dart';
import 'package:outmed/features/auth/presentation/pages/widgets/profile_type_card.dart';
import 'package:outmed/shared/widgets/custom_button.dart';

class ProfileSelectionPage extends StatelessWidget {
  const ProfileSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('select_profile'.tr)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'profile_type_hint'.tr,
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 18),
              BlocSelector<AuthBloc, AuthState, UserRole>(
                selector: (state) => state.role,
                builder: (context, role) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ProfileTypeCard(
                        title: 'healthcare_facility'.tr,
                        subtitle: 'healthcare_facility_hint'.tr,
                        image: AppAssets.healthFacility,
                        selected: role == UserRole.buyer,
                        onTap: () => context.read<AuthBloc>().add(
                          const AuthRoleSelected(UserRole.buyer),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ProfileTypeCard(
                        title: 'suppliers'.tr,
                        subtitle: 'suppliers_hint'.tr,
                        image: AppAssets.supplierWarehouse,
                        selected: role == UserRole.supplier,
                        onTap: () => context.read<AuthBloc>().add(
                          const AuthRoleSelected(UserRole.supplier),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              BlocSelector<AuthBloc, AuthState, bool>(
                selector: (state) => state.acceptedTerms,
                builder: (context, accepted) => Column(
                  children: [
                    CheckboxListTile(
                      value: accepted,
                      onChanged: (value) => context.read<AuthBloc>().add(
                        AuthTermsChanged(accepted: value ?? false),
                      ),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppColors.primary,
                      title: Text(
                        'accept_terms'.tr,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    CustomButton(
                      label: 'continue'.tr,
                      onPressed: accepted
                          ? () => AppNav.push(AppRoutes.registration)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
