import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/route_args.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/catalog/data/models/marketplace_supplier.dart';
import 'package:outmed/features/catalog/presentation/bloc/supplier_directory_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/supplier_directory_event.dart';
import 'package:outmed/features/catalog/presentation/bloc/supplier_directory_state.dart';
import 'package:outmed/features/catalog/presentation/pages/widgets/supplier_profile_body.dart';
import 'package:outmed/features/catalog/presentation/pages/widgets/supplier_profile_shimmer.dart';

class SupplierProfilePage extends StatefulWidget {
  const SupplierProfilePage({super.key});

  @override
  State<SupplierProfilePage> createState() => _SupplierProfilePageState();
}

class _SupplierProfilePageState extends State<SupplierProfilePage> {
  late final MarketplaceSupplier initial;
  var _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) return;
    _requested = true;
    initial =
        RouteArgs.maybe<Object>(context) as MarketplaceSupplier? ??
        MarketplaceSupplier.healthCare;
    if (initial.isRemote) {
      context.read<SupplierDirectoryBloc>().add(
        SupplierDirectoryDetailRequested(initial.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: Text('supplier_profile'.tr)),
      body:
          BlocSelector<
            SupplierDirectoryBloc,
            SupplierDirectoryState,
            (MarketplaceSupplier, bool)
          >(
            selector: (state) => (
              state.resolve(initial),
              state.detailStatus == LoadStatus.loading &&
                  !state.details.containsKey(initial.id),
            ),
            builder: (context, data) {
              final (supplier, loading) = data;
              if (loading && initial.isRemote) {
                return const SupplierProfileShimmer();
              }
              return SupplierProfileBody(supplier: supplier);
            },
          ),
    );
  }
}
