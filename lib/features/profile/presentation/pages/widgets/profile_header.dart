import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/profile/data/models/user_profile.dart';
import 'package:outmed/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:outmed/features/profile/presentation/bloc/profile_state.dart';
import 'package:outmed/shared/widgets/app_asset_image.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.supplier, super.key});

  final bool supplier;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, (UserProfile, bool)>(
      selector: (state) => (
        state.profile,
        state.status == LoadStatus.loading && state.profile.isEmpty,
      ),
      builder: (context, data) {
        final (profile, loading) = data;
        if (loading) return const ShimmerBox(height: 96, radius: 18);
        final title = profile.organization.isNotEmpty
            ? profile.organization
            : profile.fullName;
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: profile.logoUrl.isEmpty
                    ? const Icon(
                        Icons.business_rounded,
                        color: AppColors.primary,
                        size: 30,
                      )
                    : ClipOval(
                        child: AppAssetImage(
                          profile.logoUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isEmpty ? '-' : title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        (supplier ? 'supplier' : 'buyer').tr,
                        if (profile.email.isNotEmpty) profile.email,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.verified_rounded,
                color: Colors.white,
                size: 21,
              ),
            ],
          ),
        );
      },
    );
  }
}
