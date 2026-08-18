import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/features/catalog/data/models/marketplace_supplier.dart';
import 'package:outmed/shared/widgets/app_asset_image.dart';
import 'package:outmed/shared/widgets/custom_button.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';

class SupplierProfilePage extends StatelessWidget {
  const SupplierProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final supplier = Get.arguments as MarketplaceSupplier;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: Text('supplier_profile'.tr)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          GlossyCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                SizedBox(height: 72, child: AppAssetImage(supplier.logo)),
                const SizedBox(height: 10),
                Text(
                  supplier.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text('verified_supplier'.tr),
                    const SizedBox(width: 8),
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
              _StatCard(label: 'positive_feedback'.tr, value: '98%'),
              const SizedBox(width: 8),
              _StatCard(label: 'products'.tr, value: supplier.productsCount),
              const SizedBox(width: 8),
              _StatCard(label: 'years'.tr, value: supplier.years),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TrustChip(
                icon: Icons.local_shipping_outlined,
                label: 'fast_delivery'.tr,
              ),
              _TrustChip(
                icon: Icons.lock_outline_rounded,
                label: 'secure_payment'.tr,
              ),
              _TrustChip(icon: Icons.replay_rounded, label: 'easy_returns'.tr),
              _TrustChip(
                icon: Icons.support_agent_rounded,
                label: 'support_24'.tr,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'about_supplier'.tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            supplier.aboutKey.tr,
            style: const TextStyle(color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 24),
          CustomButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'message_supplier'.tr,
            onPressed: () =>
                Get.toNamed(AppRoutes.chat, arguments: supplier.name),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlossyCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(label),
      backgroundColor: AppColors.primarySoft,
      side: BorderSide.none,
    );
  }
}
