import 'package:outmed/core/logger/app_logger.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    AppLogger.log('Workmanager: $taskName');
    return true;
  });
}

class BackgroundSync {
  static Future<void> register() async {
    try {
      await Workmanager().initialize(callbackDispatcher);
      await Workmanager().registerPeriodicTask(
        'outmed-sync',
        'outmed-sync',
        frequency: const Duration(hours: 12),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
      );
    } on Object catch (error) {
      AppLogger.log('BackgroundSync: $error');
    }
  }
}
