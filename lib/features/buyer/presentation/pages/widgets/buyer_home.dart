import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/buyer/presentation/pages/widgets/buyer_banner.dart';
import 'package:outmed/features/buyer/presentation/pages/widgets/buyer_greeting.dart';
import 'package:outmed/features/buyer/presentation/pages/widgets/buyer_home_shimmer.dart';
import 'package:outmed/features/buyer/presentation/pages/widgets/category_strip.dart';
import 'package:outmed/features/buyer/presentation/pages/widgets/featured_products_grid.dart';
import 'package:outmed/features/buyer/presentation/pages/widgets/top_suppliers_strip.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_event.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_state.dart';
import 'package:outmed/features/catalog/presentation/bloc/category_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/category_event.dart';
import 'package:outmed/features/catalog/presentation/bloc/supplier_directory_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/supplier_directory_event.dart';
import 'package:outmed/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:outmed/features/notifications/presentation/bloc/notification_event.dart';
import 'package:outmed/shared/widgets/section_header.dart';

class BuyerHome extends StatelessWidget {
  const BuyerHome({super.key});

  Future<void> _refresh(BuildContext context) async {
    final catalog = context.read<CatalogBloc>();
    context.read<CategoryBloc>().add(const CategoryStarted());
    context.read<SupplierDirectoryBloc>().add(const SupplierDirectoryStarted());
    context.read<NotificationBloc>().add(const NotificationsStarted());
    catalog.add(const CatalogRefreshRequested());
    await catalog.stream.firstWhere(
      (state) => state.status != LoadStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: BlocSelector<CatalogBloc, CatalogState, bool>(
          selector: (state) => state.loading,
          builder: (context, loading) {
            if (loading) return const BuyerHomeShimmer();
            return RefreshIndicator(
              onRefresh: () => _refresh(context),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                children: [
                  const BuyerGreeting(),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (value) => context.read<CatalogBloc>().add(
                      CatalogSearchChanged(value),
                    ),
                    decoration: InputDecoration(
                      hintText: 'search_placeholder'.tr,
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const BuyerBanner(),
                  const SizedBox(height: 22),
                  SectionHeader(
                    title: 'shop_by_category'.tr,
                    onViewAll: () => AppNav.push(AppRoutes.allProducts),
                  ),
                  const SizedBox(height: 12),
                  const CategoryStrip(),
                  const SizedBox(height: 18),
                  SectionHeader(
                    title: 'featured_products'.tr,
                    onViewAll: () => AppNav.push(AppRoutes.allProducts),
                  ),
                  const SizedBox(height: 12),
                  const FeaturedProductsGrid(),
                  const SizedBox(height: 22),
                  SectionHeader(
                    title: 'top_suppliers'.tr,
                    onViewAll: () => AppNav.push(AppRoutes.allSuppliers),
                  ),
                  const SizedBox(height: 12),
                  const TopSuppliersStrip(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
