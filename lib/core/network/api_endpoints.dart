abstract final class ApiEndpoints {
  static const login = '/api/v1/auth/login';
  static const register = '/api/v1/auth/register';
  static const verifyOtp = '/api/v1/auth/verify-otp';
  static const resendOtp = '/api/v1/auth/resend-otp';
  static const forgotPassword = '/api/v1/auth/forgot-password';
  static const resetPassword = '/api/v1/auth/reset-password';
  static const refresh = '/api/v1/auth/refresh-token';
  static const logout = '/api/v1/auth/logout';
  static const changePassword = '/api/v1/auth/change-password';
  static const deleteAccount = '/api/v1/auth/delete-account';
  static const onboardingRole = '/api/v1/onboarding/role';
  static const buyerOnboarding = '/api/v1/onboarding/buyer/complete';
  static const supplierOnboardingStep1 = '/api/v1/onboarding/supplier/step1';
  static const supplierOnboardingStep2 = '/api/v1/onboarding/supplier/step2';
  static const supplierOnboardingStep3 = '/api/v1/onboarding/supplier/step3';
  static const products = '/api/v1/products';
  static const categories = '/api/v1/categories/all';
  static const supplierProducts = '/api/v1/supplier/products';
  static const cartItems = '/api/v1/cart/items';
  static const checkout = '/api/v1/checkout';
  static const paymentIntent = '/api/v1/payments/intent';
  static const profile = '/api/v1/profiles/me';
  static const buyerOrders = '/api/v1/orders/buyer';
  static const supplierOrders = '/api/v1/orders/supplier';
  static const supplierStats = '/api/v1/supplier/orders/stats';
  static const buyerProfile = '/api/v1/profiles/buyer';
  static const supplierProfile = '/api/v1/profiles/supplier';
  static const suppliers = '/api/v1/suppliers';
  static const topSuppliers = '/api/v1/suppliers/top';
  static const notifications = '/api/v1/notifications';
  static const notificationsReadAll = '/api/v1/notifications/read-all';
  static const faqs = '/api/v1/faqs';
  static const reportProblem = '/api/v1/support/report-problem';
  static const conversations = '/api/v1/chat/conversations';
  static const chatMessages = '/api/v1/chat/messages';
  static const cart = '/api/v1/cart';

  static String supplierProduct(String id) => '/api/v1/supplier/products/$id';

  static String supplierStock(String id) =>
      '/api/v1/supplier/products/$id/stock';

  static String orderStatus(String id) => '/api/v1/orders/$id/status';

  static String supplier(String id) => '/api/v1/suppliers/$id';

  static String notificationRead(String id) => '/api/v1/notifications/$id/read';

  static String legal(String type) => '/api/v1/legal/$type';

  static String conversationMessages(String id) =>
      '/api/v1/chat/conversations/$id/messages';

  static String conversationRead(String id) =>
      '/api/v1/chat/conversations/$id/read';

  static String cartItem(String id) => '/api/v1/cart/items/$id';
}
