import 'package:flutter/material.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/catalog/data/models/marketplace_supplier.dart';
import 'package:outmed/features/catalog/presentation/pages/widgets/supplier_stat_card.dart';
import 'package:outmed/features/catalog/presentation/pages/widgets/supplier_trust_chip.dart';
import 'package:outmed/features/catalog/presentation/widgets/supplier_logo.dart';
import 'package:outmed/features/messages/data/models/chat_thread.dart';
import 'package:outmed/shared/widgets/custom_button.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';

class SupplierProfileBody extends StatelessWidget {
  const SupplierProfileBody({required this.supplier, super.key});

  final MarketplaceSupplier supplier;

  @override
  Widget build(BuildContext context) {
    final about = supplier.about.isNotEmpty
        ? supplier.about
        : (supplier.aboutKey.isEmpty ? '' : supplier.aboutKey.tr);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      children: [
        GlossyCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              SupplierLogo(logo: supplier.logo, name: supplier.name, size: 72),
              const SizedBox(height: 10),
              Text(
                supplier.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (supplier.verified) ...[
                    const Icon(
                      Icons.verified_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text('verified_supplier'.tr),
                    const SizedBox(width: 8),
                  ],
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.warning,
                    size: 16,
                  ),
                  Text('${supplier.rating} (${supplier.reviews})'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            SupplierStatCard(
              label: 'products'.tr,
              value: supplier.productsCount,
            ),
            const SizedBox(width: 8),
            SupplierStatCard(label: 'years'.tr, value: supplier.years),
            const SizedBox(width: 8),
            SupplierStatCard(
              label: 'country'.tr,
              value: supplier.country.isEmpty ? '-' : supplier.country,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SupplierTrustChip(
              icon: Icons.local_shipping_outlined,
              label: 'fast_delivery'.tr,
            ),
            SupplierTrustChip(
              icon: Icons.lock_outline_rounded,
              label: 'secure_payment'.tr,
            ),
            SupplierTrustChip(
              icon: Icons.replay_rounded,
              label: 'easy_returns'.tr,
            ),
            SupplierTrustChip(
              icon: Icons.support_agent_rounded,
              label: 'support_24'.tr,
            ),
          ],
        ),
        if (about.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            'about_supplier'.tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            about,
            style: const TextStyle(color: AppColors.muted, height: 1.5),
          ),
        ],
        const SizedBox(height: 24),
        CustomButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'message_supplier'.tr,
          onPressed: () => AppNav.push(
            AppRoutes.chat,
            extra: ChatThread(
              title: supplier.name,
              participantUserId: supplier.userId,
            ),
          ),
        ),
      ],
    );
  }
}
