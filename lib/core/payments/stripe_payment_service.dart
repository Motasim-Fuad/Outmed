import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/l10n/app_locale.dart';
import 'package:outmed/core/logger/app_logger.dart';
import 'package:outmed/core/network/api_endpoints.dart';
import 'package:outmed/core/network/api_response.dart';

class StripePaymentService {
  StripePaymentService(this._dio);

  final Dio _dio;
  bool ready = false;

  Future<void> configure() async {
    if (AppEnv.stripePublishableKey.isEmpty || AppEnv.isTest) return;
    try {
      Stripe.publishableKey = AppEnv.stripePublishableKey;
      await Stripe.instance.applySettings();
      ready = true;
    } on Object catch (error) {
      AppLogger.log('StripePaymentService: $error');
    }
  }

  Future<String?> pay({required int amountInMinor, required String currency}) async {
    if (!ready) return null;
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.paymentIntent,
        data: {'amount': amountInMinor, 'currency': currency},
      );
      final body = response.data;
      final secret = body is Map ? body['client_secret'] as String? : null;
      if (secret == null || secret.isEmpty) {
        return AppLocale.translate('payment_failed');
      }
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: secret,
          merchantDisplayName: 'OutMed',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      return null;
    } on StripeException catch (error) {
      return error.error.message ?? AppLocale.translate('payment_failed');
    } on DioException catch (error) {
      return ApiResponse.detailMessage(error.response?.data, AppLocale.translate('payment_failed'));
    }
  }
}
