import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/catalog/data/models/marketplace_supplier.dart';
import 'package:outmed/features/catalog/presentation/bloc/supplier_directory_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/supplier_directory_event.dart';
import 'package:outmed/features/catalog/presentation/bloc/supplier_directory_state.dart';
import 'package:outmed/features/catalog/presentation/pages/widgets/supplier_list_shimmer.dart';
import 'package:outmed/features/catalog/presentation/pages/widgets/supplier_tile.dart';
import 'package:outmed/shared/widgets/inline_error_text.dart';

class AllSuppliersPage extends StatelessWidget {
  const AllSuppliersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: Text('top_suppliers'.tr)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
            child: TextField(
              onChanged: (value) => context.read<SupplierDirectoryBloc>().add(
                SupplierDirectorySearchChanged(value),
              ),
              decoration: InputDecoration(
                hintText: 'search_suppliers'.tr,
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child:
                BlocSelector<
                  SupplierDirectoryBloc,
                  SupplierDirectoryState,
                  (LoadStatus, List<MarketplaceSupplier>, String)
                >(
                  selector: (state) =>
                      (state.status, state.visible, state.errorMessage),
                  builder: (context, data) {
                    final (status, suppliers, error) = data;
                    if (status == LoadStatus.loading && suppliers.isEmpty) {
                      return const SupplierListShimmer();
                    }
                    return RefreshIndicator(
                      onRefresh: () async => context
                          .read<SupplierDirectoryBloc>()
                          .add(const SupplierDirectoryStarted()),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(18),
                        itemCount: suppliers.length + 1,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            if (suppliers.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Center(
                                  child: Text(
                                    'no_suppliers'.tr,
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return status == LoadStatus.failure
                                ? InlineErrorText(message: error)
                                : const SizedBox.shrink();
                          }
                          return SupplierTile(supplier: suppliers[index - 1]);
                        },
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
