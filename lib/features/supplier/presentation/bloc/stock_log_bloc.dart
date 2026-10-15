import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/network/api_endpoints.dart';
import 'package:outmed/core/network/api_error.dart';
import 'package:outmed/core/network/api_json.dart';
import 'package:outmed/core/network/remote_cache.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/supplier/data/models/stock_log.dart';
import 'package:outmed/features/supplier/presentation/bloc/stock_log_event.dart';
import 'package:outmed/features/supplier/presentation/bloc/stock_log_state.dart';

class StockLogBloc extends Bloc<StockLogEvent, StockLogState> {
  StockLogBloc(this._cache) : super(const StockLogState()) {
    on<StockLogsRequested>(_onRequested);
  }

  final RemoteCache _cache;

  Future<void> _onRequested(
    StockLogsRequested event,
    Emitter<StockLogState> emit,
  ) async {
    if (!AppEnv.useRemote || event.productId.isEmpty) {
      emit(state.copyWith(status: LoadStatus.success));
      return;
    }
    final path = ApiEndpoints.stockLogs(event.productId);
    emit(
      state.copyWith(
        logs: _parse(_cache.peek(path)),
        status: LoadStatus.loading,
        errorMessage: '',
      ),
    );
    try {
      emit(
        state.copyWith(
          logs: _parse(await _cache.get(path)),
          status: LoadStatus.success,
        ),
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

  List<StockLog> _parse(Object? body) {
    return [for (final row in ApiJson.maps(body)) ?StockLog.tryParse(row)]
      ..sort((a, b) {
        final left = a.createdAt;
        final right = b.createdAt;
        if (left == null || right == null) return 0;
        return right.compareTo(left);
      });
  }
}
