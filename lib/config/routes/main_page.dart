import 'package:get/get.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/features/auth/presentation/pages/auth_landing_page.dart';
import 'package:outmed/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:outmed/features/auth/presentation/pages/login_page.dart';
import 'package:outmed/features/auth/presentation/pages/new_password_page.dart';
import 'package:outmed/features/auth/presentation/pages/profile_selection_page.dart';
import 'package:outmed/features/auth/presentation/pages/registration_page.dart';
import 'package:outmed/features/auth/presentation/pages/verified_page.dart';
import 'package:outmed/features/auth/presentation/pages/verify_email_page.dart';
import 'package:outmed/features/buyer/presentation/pages/buyer_main_page.dart';
import 'package:outmed/features/catalog/presentation/pages/all_products_page.dart';
import 'package:outmed/features/catalog/presentation/pages/product_detail_page.dart';
import 'package:outmed/features/catalog/presentation/pages/all_suppliers_page.dart';
import 'package:outmed/features/catalog/presentation/pages/supplier_profile_page.dart';
import 'package:outmed/features/messages/presentation/pages/chat_page.dart';
import 'package:outmed/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:outmed/features/orders/presentation/pages/buyer_orders_page.dart';
import 'package:outmed/features/orders/presentation/pages/order_detail_page.dart';
import 'package:outmed/features/supplier/presentation/pages/add_offer_page.dart';
import 'package:outmed/features/supplier/presentation/pages/supplier_main_page.dart';
import 'package:outmed/features/supplier/presentation/pages/update_stock_page.dart';

abstract final class MainPage {
  static final pages = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.onboarding, page: OnboardingPage.new),
    GetPage(name: AppRoutes.authLanding, page: AuthLandingPage.new),
    GetPage(name: AppRoutes.login, page: LoginPage.new),
    GetPage(name: AppRoutes.profileSelection, page: ProfileSelectionPage.new),
    GetPage(name: AppRoutes.forgotPassword, page: ForgotPasswordPage.new),
    GetPage(name: AppRoutes.verifyEmail, page: VerifyEmailPage.new),
    GetPage(name: AppRoutes.newPassword, page: NewPasswordPage.new),
    GetPage(name: AppRoutes.verified, page: VerifiedPage.new),
    GetPage(name: AppRoutes.registration, page: RegistrationPage.new),
    GetPage(name: AppRoutes.buyerMain, page: BuyerMainPage.new),
    GetPage(name: AppRoutes.supplierMain, page: SupplierMainPage.new),
    GetPage(name: AppRoutes.productDetail, page: ProductDetailPage.new),
    GetPage(name: AppRoutes.allProducts, page: AllProductsPage.new),
    GetPage(name: AppRoutes.categoryProducts, page: AllProductsPage.new),
    GetPage(name: AppRoutes.addOffer, page: AddOfferPage.new),
    GetPage(name: AppRoutes.supplierInventory, page: SupplierInventoryPage.new),
    GetPage(name: AppRoutes.allSuppliers, page: AllSuppliersPage.new),
    GetPage(name: AppRoutes.supplierProfile, page: SupplierProfilePage.new),
    GetPage(name: AppRoutes.chat, page: ChatPage.new),
    GetPage(name: AppRoutes.updateStock, page: UpdateStockPage.new),
    GetPage(
      name: AppRoutes.orderSuccess,
      page: () => const OrderDetailPage(success: true),
    ),
    GetPage(name: AppRoutes.orderDetail, page: OrderDetailPage.new),
    GetPage(name: AppRoutes.buyerOrders, page: BuyerOrdersPage.new),
  ];
}
