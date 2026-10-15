import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/auth/domain/user_role.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:outmed/features/messages/data/models/chat_lookup.dart';
import 'package:outmed/features/notifications/data/models/app_notification.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';
import 'package:outmed/features/orders/presentation/bloc/order_bloc.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_bloc.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_event.dart';

abstract final class NotificationNavigator {
  static bool canOpen(AppNotification notification) =>
      notification.kind.isNotEmpty;

  static void open(BuildContext context, AppNotification notification) {
    final supplier = context.read<AuthBloc>().state.role == UserRole.supplier;
    switch (notification.kind) {
      case 'chat':
        AppNav.push(
          AppRoutes.chat,
          extra: ChatLookup(
            conversationId: notification.conversationId,
            senderId: notification.senderId,
            senderName: notification.senderName,
            preview: notification.body,
          ),
        );
      case 'order':
        if (notification.orderId.isEmpty) {
          _ordersList(context, supplier: supplier);
          return;
        }
        final order =
            context.read<OrderBloc>().state.byId(notification.orderId) ??
            OrderModel.placeholder(notification.orderId);
        AppNav.push(
          supplier
              ? '${AppRoutes.orderDetail}?from=supplier'
              : AppRoutes.orderDetail,
          extra: order,
        );
      case 'stock':
        if (supplier) {
          AppNav.push(AppRoutes.supplierInventory);
          return;
        }
        _product(context, notification.productId);
      case 'product':
        if (supplier) {
          AppNav.push(AppRoutes.supplierInventory);
          return;
        }
        _product(context, notification.productId);
      case 'account':
        AppNav.push(AppRoutes.editProfile);
      case 'support':
        AppNav.push(AppRoutes.helpSupport);
    }
  }

  static void _ordersList(BuildContext context, {required bool supplier}) {
    if (!supplier) {
      AppNav.push(AppRoutes.buyerOrders);
      return;
    }
    context.read<SupplierBloc>().add(const SupplierShellSelected(1));
    AppNav.go(AppRoutes.supplierMain);
  }

  static void _product(BuildContext context, String productId) {
    final product = context.read<CatalogBloc>().state.productById(productId);
    if (product == null) {
      AppNav.push(AppRoutes.allProducts);
      return;
    }
    AppNav.push(AppRoutes.productDetail, extra: product);
  }
}
