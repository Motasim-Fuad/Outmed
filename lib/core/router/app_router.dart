import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/di/injection.dart';
import 'package:outmed/core/feature_flags/feature_flag_service.dart';
import 'package:outmed/core/feature_flags/feature_key.dart';
import 'package:outmed/core/router/app_transition_page.dart';
import 'package:outmed/core/router/router_refresh.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:outmed/features/auth/presentation/pages/auth_landing_page.dart';
import 'package:outmed/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:outmed/features/auth/presentation/pages/login_page.dart';
import 'package:outmed/features/auth/presentation/pages/new_password_page.dart';
import 'package:outmed/features/auth/presentation/pages/profile_selection_page.dart';
import 'package:outmed/features/auth/presentation/pages/registration_page.dart';
import 'package:outmed/features/auth/presentation/pages/sign_up_page.dart';
import 'package:outmed/features/auth/presentation/pages/verified_page.dart';
import 'package:outmed/features/auth/presentation/pages/verify_email_page.dart';
import 'package:outmed/features/buyer/presentation/pages/buyer_main_page.dart';
import 'package:outmed/features/catalog/presentation/pages/all_products_page.dart';
import 'package:outmed/features/catalog/presentation/pages/all_suppliers_page.dart';
import 'package:outmed/features/catalog/presentation/pages/product_detail_page.dart';
import 'package:outmed/features/catalog/presentation/pages/supplier_profile_page.dart';
import 'package:outmed/features/messages/presentation/pages/chat_page.dart';
import 'package:outmed/features/messages/presentation/pages/messages_page.dart';
import 'package:outmed/features/notifications/presentation/pages/notifications_page.dart';
import 'package:outmed/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:outmed/features/orders/presentation/pages/buyer_orders_page.dart';
import 'package:outmed/features/orders/presentation/pages/order_detail_page.dart';
import 'package:outmed/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:outmed/features/profile/presentation/pages/security_page.dart';
import 'package:outmed/features/supplier/presentation/pages/add_offer_page.dart';
import 'package:outmed/features/supplier/presentation/pages/supplier_inventory_page.dart';
import 'package:outmed/features/supplier/presentation/pages/supplier_main_page.dart';
import 'package:outmed/features/supplier/presentation/pages/update_stock_page.dart';
import 'package:outmed/features/support/presentation/pages/help_support_page.dart';
import 'package:outmed/features/support/presentation/pages/legal_page.dart';
import 'package:outmed/features/system/presentation/pages/force_update_page.dart';
import 'package:outmed/features/system/presentation/pages/maintenance_page.dart';

class AppRouter {
  static GoRouter build(String initialLocation) {
    final refresh = RouterRefresh(getIt<AuthBloc>().stream);
    return GoRouter(
      initialLocation: initialLocation,
      refreshListenable: refresh,
      redirect: (context, state) {
        final flags = getIt<FeatureFlagService>();
        final location = state.matchedLocation;
        if (flags.isEnabled(FeatureKey.forceUpdate) &&
            location != AppRoutes.forceUpdate) {
          return AppRoutes.forceUpdate;
        }
        if (flags.isEnabled(FeatureKey.maintenance) &&
            location != AppRoutes.maintenance) {
          return AppRoutes.maintenance;
        }
        final authenticated = getIt<AuthBloc>().state.authenticated;
        if (!authenticated && !_public.contains(location)) {
          return AppRoutes.login;
        }
        if (!flags.isEnabled(FeatureKey.messages) &&
            location == AppRoutes.messages) {
          return AppRoutes.buyerMain;
        }
        return null;
      },
      routes: [
        _route(AppRoutes.onboarding, const OnboardingPage()),
        _route(AppRoutes.authLanding, const AuthLandingPage()),
        _route(AppRoutes.login, const LoginPage()),
        _route(AppRoutes.profileSelection, const ProfileSelectionPage()),
        _route(AppRoutes.forgotPassword, const ForgotPasswordPage()),
        _route(AppRoutes.verifyEmail, const VerifyEmailPage()),
        _route(AppRoutes.newPassword, const NewPasswordPage()),
        _route(AppRoutes.verified, const VerifiedPage()),
        _route(AppRoutes.signUp, const SignUpPage()),
        _route(AppRoutes.registration, const RegistrationPage()),
        _route(AppRoutes.buyerMain, const BuyerMainPage()),
        _route(AppRoutes.supplierMain, const SupplierMainPage()),
        _route(AppRoutes.productDetail, const ProductDetailPage()),
        _route(AppRoutes.allProducts, const AllProductsPage()),
        _route(AppRoutes.categoryProducts, const AllProductsPage()),
        _route(AppRoutes.addOffer, const AddOfferPage()),
        _route(AppRoutes.supplierInventory, const SupplierInventoryPage()),
        _route(AppRoutes.allSuppliers, const AllSuppliersPage()),
        _route(AppRoutes.supplierProfile, const SupplierProfilePage()),
        _route(AppRoutes.chat, const ChatPage()),
        _route(AppRoutes.updateStock, const UpdateStockPage()),
        _route(AppRoutes.buyerOrders, const BuyerOrdersPage()),
        _route(AppRoutes.orderDetail, const OrderDetailPage()),
        _route(AppRoutes.orderSuccess, const OrderDetailPage(success: true)),
        GoRoute(
          path: AppRoutes.messages,
          pageBuilder: (context, state) => AppTransitionPage(
            name: AppRoutes.messages,
            child: MessagesPage(
              showBack: state.uri.queryParameters['back'] == '1',
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.editProfile,
          pageBuilder: (context, state) => AppTransitionPage(
            name: AppRoutes.editProfile,
            child: EditProfilePage(
              addressOnly: state.uri.queryParameters['section'] == 'address',
            ),
          ),
        ),
        _route(AppRoutes.security, const SecurityPage()),
        _route(AppRoutes.notifications, const NotificationsPage()),
        _route(AppRoutes.helpSupport, const HelpSupportPage()),
        GoRoute(
          path: AppRoutes.legal,
          pageBuilder: (context, state) => AppTransitionPage(
            name: AppRoutes.legal,
            child: LegalPage(
              type: state.uri.queryParameters['type'] ?? 'TERMS_AND_CONDITIONS',
            ),
          ),
        ),
        _route(AppRoutes.maintenance, const MaintenancePage()),
        _route(AppRoutes.forceUpdate, const ForceUpdatePage()),
      ],
    );
  }

  static GoRoute _route(String path, Widget child) {
    return GoRoute(
      path: path,
      pageBuilder: (context, state) =>
          AppTransitionPage(name: path, child: child),
    );
  }

  static const Set<String> _public = {
    AppRoutes.onboarding,
    AppRoutes.authLanding,
    AppRoutes.login,
    AppRoutes.profileSelection,
    AppRoutes.forgotPassword,
    AppRoutes.verifyEmail,
    AppRoutes.newPassword,
    AppRoutes.verified,
    AppRoutes.signUp,
    AppRoutes.registration,
    AppRoutes.legal,
    AppRoutes.maintenance,
    AppRoutes.forceUpdate,
  };
}
