import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/network/api_endpoints.dart';
import 'package:outmed/core/network/api_error.dart';
import 'package:outmed/core/network/api_json.dart';
import 'package:outmed/core/network/remote_cache.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/catalog/data/models/marketplace_supplier.dart';
import 'package:outmed/features/catalog/presentation/bloc/supplier_directory_event.dart';
import 'package:outmed/features/catalog/presentation/bloc/supplier_directory_state.dart';

class SupplierDirectoryBloc
    extends Bloc<SupplierDirectoryEvent, SupplierDirectoryState> {
  SupplierDirectoryBloc(this._cache)
    : super(
        AppEnv.useRemote
            ? const SupplierDirectoryState(suppliers: [], top: [])
            : const SupplierDirectoryState(),
      ) {
    on<SupplierDirectoryStarted>(_onStarted);
    on<SupplierDirectorySearchChanged>(_onSearch);
    on<SupplierDirectoryDetailRequested>(_onDetail);
  }

  static const _listQuery = {'page': 1, 'limit': 50};

  final RemoteCache _cache;

  Future<void> _onStarted(
    SupplierDirectoryStarted event,
    Emitter<SupplierDirectoryState> emit,
  ) async {
    if (!AppEnv.useRemote) {
      emit(state.copyWith(status: LoadStatus.success));
      return;
    }
    final cachedAll = _parse(
      _cache.peek(ApiEndpoints.suppliers, query: _listQuery),
    );
    final cachedTop = _parse(_cache.peek(ApiEndpoints.topSuppliers));
    emit(
      state.copyWith(
        suppliers: cachedAll.isEmpty ? null : cachedAll,
        top: cachedTop.isEmpty ? null : cachedTop,
        status: cachedAll.isEmpty && cachedTop.isEmpty
            ? LoadStatus.loading
            : LoadStatus.success,
        errorMessage: '',
      ),
    );
    try {
      final results = await Future.wait([
        _cache.get(ApiEndpoints.suppliers, query: _listQuery),
        _cache.get(ApiEndpoints.topSuppliers),
      ]);
      final all = _parse(results[0]);
      final top = _parse(results[1]);
      emit(
        state.copyWith(
          suppliers: all,
          top: top.isNotEmpty ? top : all,
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

  void _onSearch(
    SupplierDirectorySearchChanged event,
    Emitter<SupplierDirectoryState> emit,
  ) {
    emit(state.copyWith(query: event.query));
  }

  Future<void> _onDetail(
    SupplierDirectoryDetailRequested event,
    Emitter<SupplierDirectoryState> emit,
  ) async {
    if (event.id.isEmpty || !AppEnv.useRemote) return;
    emit(
      state.copyWith(
        detailStatus: state.details.containsKey(event.id)
            ? LoadStatus.success
            : LoadStatus.loading,
      ),
    );
    try {
      final body = await _cache.get(ApiEndpoints.supplier(event.id));
      final json = ApiJson.asMap(ApiJson.unwrap(body));
      final supplier = json == null ? null : MarketplaceSupplier.tryParse(json);
      emit(
        state.copyWith(
          details: supplier == null
              ? null
              : {...state.details, event.id: supplier},
          detailStatus: LoadStatus.success,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          detailStatus: LoadStatus.failure,
          errorMessage: ApiError.message(error),
        ),
      );
    }
  }

  List<MarketplaceSupplier> _parse(Object? body) {
    return ApiJson.maps(
          body,
        )
        .map(MarketplaceSupplier.tryParse)
        .whereType<MarketplaceSupplier>()
        .toList(
          growable: false,
        );
  }
}
