abstract final class ApiEndpoints {
  static const login = '/api/auth/login';
  static const register = '/api/auth/register';
  static const refresh = '/api/auth/refresh';
  static const products = '/api/products';
  static const offers = '/api/offers';
  static const orders = '/api/orders';
  static const paymentIntent = '/api/payments/intent';

  static String offer(String id) => '/api/offers/$id';
}
