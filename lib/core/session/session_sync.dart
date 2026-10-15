import 'dart:async';

import 'package:outmed/core/di/injection.dart';
import 'package:outmed/core/network/offline_queue.dart';
import 'package:outmed/features/auth/domain/user_role.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_event.dart';
import 'package:outmed/features/catalog/presentation/bloc/category_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/category_event.dart';
import 'package:outmed/features/catalog/presentation/bloc/supplier_directory_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/supplier_directory_event.dart';
import 'package:outmed/features/messages/presentation/bloc/chat_bloc.dart';
import 'package:outmed/features/messages/presentation/bloc/chat_event.dart';
import 'package:outmed/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:outmed/features/notifications/presentation/bloc/notification_event.dart';
import 'package:outmed/features/orders/presentation/bloc/order_bloc.dart';
import 'package:outmed/features/orders/presentation/bloc/order_event.dart';
import 'package:outmed/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:outmed/features/profile/presentation/bloc/profile_event.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_bloc.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_event.dart';

abstract final class SessionSync {
  static void signedIn(UserRole role) {
    unawaited(getIt<OfflineQueue>().flush());
    getIt<OrderBloc>().add(const OrderStarted());
    getIt<ProfileBloc>().add(const ProfileStarted());
    getIt<NotificationBloc>().add(const NotificationsStarted());
    getIt<ChatBloc>().add(const ChatStarted());
    getIt<CategoryBloc>().add(const CategoryStarted());
    if (role == UserRole.supplier) {
      getIt<SupplierBloc>().add(const SupplierStatsRequested());
    } else {
      getIt<SupplierDirectoryBloc>().add(const SupplierDirectoryStarted());
      getIt<CartBloc>().add(const CartSyncRequested());
    }
  }

  static void signedOut() {
    getIt<ProfileBloc>().add(const ProfileReset());
    getIt<NotificationBloc>().add(const NotificationsReset());
    getIt<ChatBloc>().add(const ChatReset());
    getIt<CartBloc>().add(const CartCleared());
    getIt<OrderBloc>().add(const OrderReset());
  }
}
