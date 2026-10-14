import 'package:outmed/core/logger/app_logger.dart';

class AnalyticsService {
  void screen(String name) => AppLogger.log('Analytics: screen $name');

  void event(String name, [Map<String, Object?> parameters = const {}]) {
    AppLogger.log('Analytics: $name $parameters');
  }
}
