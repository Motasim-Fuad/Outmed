import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/logger/app_logger.dart';
import 'package:outmed/core/network/api_error.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_event.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc(this._repository) : super(const CatalogState()) {
    on<CatalogStarted>(_load);
    on<CatalogRefreshRequested>(_load);
    on<CatalogSearchChanged>(_search);
    on<CatalogProductRequested>(_product);
    add(const CatalogStarted());
  }

  final CatalogRepository _repository;

  List<ProductModel> get products => state.products;
  List<ProductModel> get visibleProducts => state.visibleProducts;
  List<SupplierOfferModel> offersFor(String productId) =>
      state.offersFor(productId);
  SupplierOfferModel? bestOfferFor(String productId) =>
      state.bestOfferFor(productId);

  Future<void> _load(CatalogEvent event, Emitter<CatalogState> emit) async {
    AppLogger.log('CatalogBloc: ${event.runtimeType}');
    final local = _repository.getProducts();
    emit(
      state.copyWith(
        products: local,
        offers: _repository.getOffers(),
        status: AppEnv.useRemote ? LoadStatus.loading : LoadStatus.success,
        errorMessage: '',
        revision: state.revision + 1,
      ),
    );
    if (!AppEnv.useRemote) return;
    try {
      await _repository.refreshRemote();
      emit(
        state.copyWith(
          status: LoadStatus.success,
          products: _repository.getProducts(),
          offers: _repository.getOffers(),
          revision: state.revision + 1,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: LoadStatus.failure,
          errorMessage: ApiError.message(error),
          revision: state.revision + 1,
        ),
      );
    }
  }

  Future<void> _product(
    CatalogProductRequested event,
    Emitter<CatalogState> emit,
  ) async {
    try {
      await _repository.refreshProduct(event.productId);
      emit(
        state.copyWith(
          products: _repository.getProducts(),
          offers: _repository.getOffers(),
          revision: state.revision + 1,
        ),
      );
    } on Object catch (error) {
      AppLogger.log('CatalogBloc: product detail failed $error');
    }
  }

  void _search(CatalogSearchChanged event, Emitter<CatalogState> emit) {
    emit(
      state.copyWith(searchQuery: event.query, revision: state.revision + 1),
    );
  }
}
