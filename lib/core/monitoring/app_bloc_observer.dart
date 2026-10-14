import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/logger/app_logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    AppLogger.log('${bloc.runtimeType}: create');
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    AppLogger.log('${bloc.runtimeType}: ${event.runtimeType}');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    AppLogger.log('${bloc.runtimeType}: change');
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    AppLogger.log('${bloc.runtimeType}: close');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLogger.log('${bloc.runtimeType}: error $error');
    super.onError(bloc, error, stackTrace);
  }
}
