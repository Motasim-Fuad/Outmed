import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/buyer/presentation/pages/widgets/order_shortcut.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_state.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';

class BuyerCategoriesTab extends StatefulWidget {
  const BuyerCategoriesTab({super.key});

  @override
  State<BuyerCategoriesTab> createState() => _BuyerCategoriesTabState();
}

class _BuyerCategoriesTabState extends State<BuyerCategoriesTab> {
  static const List<(String, IconData, String)> _categories = [
    ('PPE & Safety', Icons.health_and_safety_outlined, 'ppe'),
    ('Surgical', Icons.cut_rounded, 'surgical_instruments'),
    ('Diagnostic', Icons.biotech_outlined, 'diagnostic'),
    ('Dental', Icons.medication_liquid_outlined, 'dental'),
    ('Cardiology', Icons.favorite_outline_rounded, 'cardiology'),
    ('Emergency Care', Icons.medical_services_outlined, 'emergency_care'),
    ('Laboratory', Icons.science_outlined, 'laboratory'),
  ];

  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final visible = _categories
        .where(
          (item) =>
              query.isEmpty ||
              item.$1.toLowerCase().contains(query) ||
              item.$3.tr.toLowerCase().contains(query),
        )
        .toList();
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
          children: [
            Text(
              'all_categories'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'search_placeholder'.tr,
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            BlocSelector<CatalogBloc, CatalogState, Map<String, int>>(
              selector: (state) {
                final counts = <String, int>{};
                for (final product in state.products) {
                  counts.update(
                    product.category,
                    (count) => count + 1,
                    ifAbsent: () => 1,
                  );
                }
                return counts;
              },
              builder: (context, counts) => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: .86,
                ),
                itemCount: visible.length,
                itemBuilder: (context, index) {
                  final category = visible[index];
                  return GlossyCard(
                    onTap: () => AppNav.push(
                      AppRoutes.categoryProducts,
                      extra: category.$1,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(category.$2, color: AppColors.primary, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          category.$3.tr,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${counts[category.$1] ?? 0} ${'products'.tr}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'recent_orders'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => AppNav.push(AppRoutes.buyerOrders),
                  child: Text('view_all'.tr),
                ),
              ],
            ),
            const OrderShortcut(),
          ],
        ),
      ),
    );
  }
}
