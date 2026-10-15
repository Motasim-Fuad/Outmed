import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';

extension OrderStatusLabel on OrderModel {
  bool get supplierCanAdvance => !cancelled && status != OrderStatus.delivered;

  OrderStatus get supplierNextStatus => AppEnv.useRemote
      ? OrderModel.nextRemoteStatus(status)
      : OrderStatus.values[(status.index + 1).clamp(
          0,
          OrderStatus.values.length - 1,
        )];

  String get supplierNextAction {
    return switch (supplierNextStatus) {
      OrderStatus.pending || OrderStatus.confirmed => 'confirm_order'.tr,
      OrderStatus.preparing => 'mark_preparing'.tr,
      OrderStatus.readyForPickup => 'mark_ready'.tr,
      OrderStatus.inTransit => 'move_to_in_transit'.tr,
      OrderStatus.delivered => 'mark_delivered'.tr,
    };
  }

  String get buyerLabel {
    if (cancelled) return 'cancelled'.tr;
    return switch (status) {
      OrderStatus.pending => 'pending_confirmation'.tr,
      OrderStatus.confirmed => 'confirmed'.tr,
      OrderStatus.preparing => 'preparing'.tr,
      OrderStatus.readyForPickup => 'ready_for_pickup'.tr,
      OrderStatus.inTransit => 'in_transit'.tr,
      OrderStatus.delivered => 'delivered'.tr,
    };
  }
}
