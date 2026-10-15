import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/di/injection.dart';
import 'package:outmed/main.dart';

void main() {
  setUp(() async {
    await getIt.reset();
  });

  testWidgets('shows localized OutMed onboarding', (tester) async {
    await tester.pumpWidget(const OutMedApp());
    await tester.pumpAndSettle();

    expect(find.text('Find trusted medical suppliers'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('renders Arabic login without layout errors', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const OutMedApp(
        initialLocation: AppRoutes.login,
        locale: Locale('ar', 'SA'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('مرحباً بعودتك'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final route in [AppRoutes.buyerMain, AppRoutes.supplierMain]) {
    testWidgets('renders Arabic $route shell without overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        OutMedApp(
          initialLocation: route,
          locale: const Locale('ar', 'SA'),
          startAuthenticated: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}
