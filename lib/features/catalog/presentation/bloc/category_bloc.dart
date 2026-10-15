import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/network/api_endpoints.dart';
import 'package:outmed/core/network/api_error.dart';
import 'package:outmed/core/network/remote_cache.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/catalog/presentation/bloc/category_event.dart';
import 'package:outmed/features/catalog/presentation/bloc/category_state.dart';
import 'package:outmed/features/supplier/data/models/category_option.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc(this._cache) : super(const CategoryState()) {
    on<CategoryStarted>(_onStarted);
  }

  static const _demo = [
    CategoryOption(id: 'PPE & Safety', name: 'PPE & Safety'),
    CategoryOption(id: 'Surgical', name: 'Surgical'),
    CategoryOption(id: 'Diagnostic', name: 'Diagnostic'),
    CategoryOption(id: 'Dental', name: 'Dental'),
    CategoryOption(id: 'Laboratory', name: 'Laboratory'),
  ];

  final RemoteCache _cache;

  Future<void> _onStarted(
    CategoryStarted event,
    Emitter<CategoryState> emit,
  ) async {
    if (!AppEnv.useRemote) {
      emit(state.copyWith(categories: _demo, status: LoadStatus.success));
      return;
    }
    final cached = CategoryOption.parseList(
      _cache.peek(ApiEndpoints.categories),
    );
    emit(
      state.copyWith(
        categories: cached.isEmpty ? null : cached,
        status: LoadStatus.loading,
        errorMessage: '',
      ),
    );
    try {
      final body = await _cache.get(ApiEndpoints.categories);
      emit(
        state.copyWith(
          categories: CategoryOption.parseList(body),
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
}
