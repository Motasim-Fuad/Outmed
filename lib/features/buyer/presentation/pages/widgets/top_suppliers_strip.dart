import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/features/buyer/presentation/pages/widgets/buyer_supplier_card.dart';
import 'package:outmed/features/catalog/data/models/marketplace_supplier.dart';
import 'package:outmed/features/catalog/presentation/bloc/supplier_directory_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/supplier_directory_state.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class TopSuppliersStrip extends StatelessWidget {
  const TopSuppliersStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 188,
      child:
          BlocSelector<
            SupplierDirectoryBloc,
            SupplierDirectoryState,
            (bool, List<MarketplaceSupplier>)
          >(
            selector: (state) => (
              state.loading,
              state.top.isNotEmpty ? state.top : state.suppliers,
            ),
            builder: (context, data) {
              final suppliers = data.$2;
              if (data.$1 && suppliers.isEmpty) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, _) =>
                      const ShimmerBox(height: 188, width: 168, radius: 16),
                );
              }
              if (suppliers.isEmpty) {
                return Center(
                  child: Text(
                    'no_suppliers'.tr,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                );
              }
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: suppliers.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) => SizedBox(
                  width: 168,
                  child: BuyerSupplierCard(supplier: suppliers[index]),
                ),
              );
            },
          ),
    );
  }
}
