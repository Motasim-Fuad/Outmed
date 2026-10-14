import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/app.dart';
import 'package:outmed/core/background/background_sync.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/connectivity/connectivity_service.dart';
import 'package:outmed/core/di/injection.dart';
import 'package:outmed/core/logger/app_logger.dart';
import 'package:outmed/core/monitoring/app_bloc_observer.dart';
import 'package:outmed/core/monitoring/firebase_bootstrap.dart';
import 'package:outmed/core/payments/stripe_payment_service.dart';
import 'package:outmed/core/storage/app_database.dart';
import 'package:outmed/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:outmed/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_event.dart';
import 'package:outmed/shared/widgets/app_error_screen.dart';

export 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  ErrorWidget.builder = (details) => const AppErrorScreen();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  AppScope.ensure();
  runApp(const OutMedApp());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_startDeferred());
  });
}

Future<void> _startDeferred() async {
  ConnectivityService.instance.start();
  await getIt<StripePaymentService>().configure();
  await FirebaseBootstrap.start();
  if (AppEnv.isTest) return;
  try {
    final database = await AppDatabase.open();
    await (getIt<CatalogRepository>() as CatalogRepositoryImpl).bindLocal(database);
    getIt<CatalogBloc>().add(const CatalogRefreshRequested());
    await BackgroundSync.register();
  } on Object catch (error) {
    AppLogger.log('Bootstrap: $error');
  }
}
