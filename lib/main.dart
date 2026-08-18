import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/config/routes/main_page.dart';
import 'package:outmed/core/config/localization/app_translations.dart';
import 'package:outmed/core/config/localization/localization_config.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/di/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const OutMedApp());
}

class OutMedApp extends StatelessWidget {
  const OutMedApp({
    this.initialRoute = AppRoutes.onboarding,
    this.locale = LocalizationConfig.fallbackLocale,
    super.key,
  });

  final String initialRoute;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: Colors.white,
    );
    return GetMaterialApp(
      title: 'OutMed',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: MainPage.pages,
      initialBinding: Injection.initialBinding,
      translations: AppTranslations(),
      locale: locale,
      fallbackLocale: LocalizationConfig.fallbackLocale,
      supportedLocales: LocalizationConfig.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
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
        navigationBarTheme: const NavigationBarThemeData(
          surfaceTintColor: Colors.transparent,
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: AppColors.muted),
          hintStyle: const TextStyle(color: AppColors.muted),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
