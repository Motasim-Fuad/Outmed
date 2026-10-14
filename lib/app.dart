import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/config/localization/localization_config.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/di/injection.dart';
import 'package:outmed/core/l10n/app_locale.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/auth/domain/user_role.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_state.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:outmed/features/orders/presentation/bloc/order_bloc.dart';
import 'package:outmed/features/orders/presentation/bloc/order_state.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_bloc.dart';
import 'package:outmed/shared/widgets/offline_banner.dart';

class OutMedApp extends StatelessWidget {
  const OutMedApp({
    this.initialLocation = AppRoutes.onboarding,
    this.locale = LocalizationConfig.fallbackLocale,
    this.startAuthenticated = false,
    super.key,
  });

  final String initialLocation;
  final Locale locale;
  final bool startAuthenticated;

  @override
  Widget build(BuildContext context) {
    AppScope.ensure(
      initialLocation: initialLocation,
      startAuthenticated: startAuthenticated,
      locale: locale,
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthBloc>()),
        BlocProvider.value(value: getIt<CatalogBloc>()),
        BlocProvider.value(value: getIt<CartBloc>()),
        BlocProvider.value(value: getIt<OrderBloc>()),
        BlocProvider.value(value: getIt<SupplierBloc>()),
      ],
      child: ListenableBuilder(
        listenable: AppLocale.instance,
        builder: (context, _) {
          return BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) => previous.authenticated && !current.authenticated,
            listener: (context, state) => AppNav.go(AppRoutes.authLanding),
            child: BlocListener<AuthBloc, AuthState>(
              listenWhen: (previous, current) =>
                  !previous.authenticated &&
                  current.authenticated &&
                  current.status == LoadStatus.success,
              listener: (context, state) {
                AppNav.go(
                  state.role == UserRole.supplier ? AppRoutes.supplierMain : AppRoutes.buyerMain,
                );
              },
              child: BlocListener<OrderBloc, OrderState>(
              listenWhen: (previous, current) => previous.placedOrder?.id != current.placedOrder?.id && current.placedOrder != null,
              listener: (context, state) => AppNav.push(AppRoutes.orderSuccess, extra: state.placedOrder),
              child: MaterialApp.router(
                title: 'OutMed',
                debugShowCheckedModeBanner: false,
                routerConfig: AppNav.router,
                locale: AppLocale.instance.locale,
                supportedLocales: LocalizationConfig.supportedLocales,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                builder: (context, child) {
                  return Column(
                    children: [
                      const OfflineBanner(),
                      Expanded(child: child ?? const SizedBox.shrink()),
                    ],
                  );
                },
                theme: ThemeData(
                  useMaterial3: true,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: AppColors.primary,
                    primary: AppColors.primary,
                    surface: Colors.white,
                  ),
                  scaffoldBackgroundColor: AppColors.canvas,
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.ink,
                    centerTitle: false,
                    elevation: 0,
                    surfaceTintColor: Colors.transparent,
                    titleTextStyle: TextStyle(
                      color: AppColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            ),
          );
        },
      ),
    );
  }
}
