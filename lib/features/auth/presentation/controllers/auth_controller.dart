import 'dart:async';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:outmed/config/routes/app_routes.dart';

enum UserRole { buyer, supplier }

class AuthController extends GetxController {
  final selectedRole = UserRole.buyer.obs;
  final obscurePassword = true.obs;
  final acceptedTerms = false.obs;

  void selectRole(UserRole role) => selectedRole.value = role;

  void toggleRole() {
    selectedRole.value = selectedRole.value == UserRole.buyer
        ? UserRole.supplier
        : UserRole.buyer;
  }

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  void login() {
    Get.offAllNamed(
      selectedRole.value == UserRole.buyer
          ? AppRoutes.buyerMain
          : AppRoutes.supplierMain,
    );
  }

  void changeLanguage(Locale locale) {
    unawaited(Get.updateLocale(locale));
  }

  void logout() {
    selectedRole.value = UserRole.buyer;
    Get.offAllNamed(AppRoutes.authLanding);
  }
}
