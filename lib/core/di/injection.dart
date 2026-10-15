import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/analytics/analytics_service.dart';
import 'package:outmed/core/feature_flags/feature_flag_service.dart';
import 'package:outmed/core/l10n/app_locale.dart';
import 'package:outmed/core/network/dio_factory.dart';
import 'package:outmed/core/network/offline_queue.dart';
import 'package:outmed/core/network/remote_cache.dart';
import 'package:outmed/core/payments/stripe_payment_service.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/core/router/app_router.dart';
import 'package:outmed/core/storage/token_store.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_event.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:outmed/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:outmed/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/category_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/category_event.dart';
import 'package:outmed/features/catalog/presentation/bloc/supplier_directory_bloc.dart';
import 'package:outmed/features/messages/presentation/bloc/chat_bloc.dart';
import 'package:outmed/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:outmed/features/orders/presentation/bloc/order_bloc.dart';
import 'package:outmed/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:outmed/features/supplier/data/supplier_remote.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_bloc.dart';
import 'package:outmed/features/support/presentation/bloc/support_bloc.dart';

final GetIt getIt = GetIt.instance;

class AppScope {
  static void ensure({
    String initialLocation = AppRoutes.onboarding,
    bool startAuthenticated = false,
    Locale? locale,
  }) {
    if (locale != null) {
      AppLocale.instance.setLocale(locale);
    }
    if (getIt.isRegistered<AuthBloc>()) return;
    final tokens = TokenStore();
    final dio = DioFactory.create(
      tokens: tokens,
      onRefreshFailed: () {
        if (getIt.isRegistered<AuthBloc>()) {
          getIt<AuthBloc>().add(const AuthSessionExpired());
        }
      },
    );
    final cache = RemoteCache(dio);
    final queue = OfflineQueue(dio);
    getIt
      ..registerSingleton<TokenStore>(tokens)
      ..registerSingleton<Dio>(dio)
      ..registerSingleton<RemoteCache>(cache)
      ..registerSingleton<OfflineQueue>(queue)
      ..registerSingleton<FeatureFlagService>(FeatureFlagService())
      ..registerSingleton<AnalyticsService>(AnalyticsService())
      ..registerSingleton<StripePaymentService>(StripePaymentService(dio))
      ..registerLazySingleton<CatalogRepository>(
        () => CatalogRepositoryImpl(cache),
      )
      ..registerLazySingleton<AuthBloc>(
        () => AuthBloc(
          tokens: tokens,
          dio: dio,
          cache: cache,
          authenticated: startAuthenticated,
        ),
      )
      ..registerLazySingleton<CatalogBloc>(
        () => CatalogBloc(getIt<CatalogRepository>()),
      )
      ..registerLazySingleton<CartBloc>(() => CartBloc(cache, queue))
      ..registerLazySingleton<OrderBloc>(
        () => OrderBloc(
          getIt<CatalogRepository>(),
          getIt<CartBloc>(),
          getIt<Dio>(),
          getIt<AuthBloc>(),
          cache,
          () => getIt<ProfileBloc>().state.profile,
        ),
      )
      ..registerLazySingleton<SupplierBloc>(
        () => SupplierBloc(
          getIt<CatalogRepository>(),
          getIt<CatalogBloc>(),
          SupplierRemote(cache, queue),
          () => getIt<ProfileBloc>().state.profile.organization,
        ),
      )
      ..registerLazySingleton<CategoryBloc>(
        () => CategoryBloc(cache)..add(const CategoryStarted()),
      )
      ..registerLazySingleton<SupplierDirectoryBloc>(
        () => SupplierDirectoryBloc(cache),
      )
      ..registerLazySingleton<ChatBloc>(
        () => ChatBloc(dio, cache, queue, tokens),
      )
      ..registerLazySingleton<ProfileBloc>(
        () => ProfileBloc(dio, cache, getIt<AuthBloc>()),
      )
      ..registerLazySingleton<NotificationBloc>(
        () => NotificationBloc(cache, queue),
      )
      ..registerLazySingleton<SupportBloc>(() => SupportBloc(cache, queue));
    final router = AppRouter.build(initialLocation);
    AppNav.router = router;
    getIt.registerSingleton<GoRouter>(router);
  }
}
