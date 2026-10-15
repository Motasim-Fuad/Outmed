import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/network/api_endpoints.dart';
import 'package:outmed/core/network/api_error.dart';
import 'package:outmed/core/network/api_json.dart';
import 'package:outmed/core/network/remote_cache.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/profile/data/models/login_activity.dart';
import 'package:outmed/features/profile/presentation/bloc/login_activity_event.dart';
import 'package:outmed/features/profile/presentation/bloc/login_activity_state.dart';

class LoginActivityBloc extends Bloc<LoginActivityEvent, LoginActivityState> {
  LoginActivityBloc(this._cache) : super(const LoginActivityState()) {
    on<LoginActivitiesRequested>(_onRequested);
  }

  final RemoteCache _cache;

  Future<void> _onRequested(
    LoginActivitiesRequested event,
    Emitter<LoginActivityState> emit,
  ) async {
    if (!AppEnv.useRemote) {
      emit(state.copyWith(status: LoadStatus.success));
      return;
    }
    emit(
      state.copyWith(
        activities: _parse(_cache.peek(ApiEndpoints.loginActivities)),
        status: LoadStatus.loading,
        errorMessage: '',
      ),
    );
    try {
      final body = await _cache.get(ApiEndpoints.loginActivities);
      emit(
        state.copyWith(activities: _parse(body), status: LoadStatus.success),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: LoadStatus.failure,
          errorMessage: ApiError.message(error),
        ),
      );
    }
  }

  List<LoginActivity> _parse(Object? body) => [
    for (final row in ApiJson.maps(body)) ?LoginActivity.tryParse(row),
  ];
}
