import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/inventory_body.dart';

class SupplierInventoryPage extends StatelessWidget {
  const SupplierInventoryPage({this.embedded = false, super.key});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: embedded ? null : AppBar(title: Text('inventory'.tr)),
      body: const SafeArea(child: InventoryBody()),
    );
  }
}
