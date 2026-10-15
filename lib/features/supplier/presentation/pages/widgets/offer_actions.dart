import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_bloc.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_event.dart';

class OfferActions extends StatelessWidget {
  const OfferActions({required this.offer, super.key});

  final SupplierOfferModel offer;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('delete_offer'.tr),
        content: Text('confirm_delete_offer'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<SupplierBloc>().add(SupplierOfferDeleteRequested(offer.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'edit_offer'.tr,
      padding: EdgeInsets.zero,
      onSelected: (value) {
        switch (value) {
          case 'stock':
            AppNav.push(AppRoutes.updateStock, extra: offer);
          case 'edit':
            AppNav.push(AppRoutes.addOffer, extra: offer);
          case 'delete':
            unawaited(_confirmDelete(context));
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'stock', child: Text('update_stock'.tr)),
        PopupMenuItem(value: 'edit', child: Text('edit_offer'.tr)),
        PopupMenuItem(
          value: 'delete',
          child: Text(
            'delete_offer'.tr,
            style: const TextStyle(color: AppColors.danger),
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary),
        ),
        child: const Icon(
          Icons.more_horiz_rounded,
          size: 16,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
