import 'package:flutter/material.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/shared/widgets/app_text_field.dart';

class ShippingDetailsDialog extends StatefulWidget {
  const ShippingDetailsDialog({super.key});

  @override
  State<ShippingDetailsDialog> createState() => _ShippingDetailsDialogState();
}

class _ShippingDetailsDialogState extends State<ShippingDetailsDialog> {
  final courierController = TextEditingController();
  final trackingController = TextEditingController();

  @override
  void dispose() {
    courierController.dispose();
    trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('shipping_details'.tr),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            controller: courierController,
            label: '${'courier_name'.tr} (${'optional'.tr})',
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: trackingController,
            label: '${'tracking_number'.tr} (${'optional'.tr})',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, (
            courierController.text.trim(),
            trackingController.text.trim(),
          )),
          child: Text('move_to_in_transit'.tr),
        ),
      ],
    );
  }
}
