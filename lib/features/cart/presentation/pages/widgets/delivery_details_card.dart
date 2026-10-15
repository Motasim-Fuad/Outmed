import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:outmed/features/profile/presentation/bloc/profile_state.dart';

class DeliveryDetailsCard extends StatelessWidget {
  const DeliveryDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: BlocSelector<ProfileBloc, ProfileState, String>(
        selector: (state) => state.profile.addressLine,
        builder: (context, address) => Row(
          children: [
            const Icon(Icons.location_on_outlined, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'delivery_address'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.isEmpty ? 'add_delivery_address'.tr : address,
                    style: TextStyle(
                      color: address.isEmpty
                          ? AppColors.danger
                          : AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () =>
                  AppNav.push('${AppRoutes.editProfile}?section=address'),
              child: Text(address.isEmpty ? 'add'.tr : 'edit'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
