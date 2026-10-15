import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/l10n/app_locale.dart';
import 'package:outmed/core/logger/app_logger.dart';
import 'package:outmed/core/network/api_error.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_event.dart';
import 'package:outmed/features/supplier/data/supplier_remote.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_event.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_state.dart';

class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  SupplierBloc(
    this._repository,
    this._catalog,
    this._remote,
    this._supplierName,
  ) : super(const SupplierState()) {
    on<SupplierStarted>(_start);
    on<SupplierStatsRequested>(_stats);
    on<SupplierShellSelected>(_shell);
    on<SupplierSearchChanged>(_search);
    on<SupplierProductSelected>(_select);
    on<SupplierSelectionCleared>(_clear);
    on<SupplierFeedbackCleared>(_feedback);
    on<SupplierProductCreateRequested>(_create);
    on<SupplierOfferSaveRequested>(_save);
    on<SupplierStockAdjusted>(_adjust);
    on<SupplierOfferDeleteRequested>(_delete);
    add(const SupplierStarted());
  }

  static const demoSupplierName = 'HealthCare Supplies';

  final CatalogRepository _repository;
  final CatalogBloc _catalog;
  final SupplierRemote _remote;
  final String Function() _supplierName;

  String get supplierName {
    final name = _supplierName();
    return name.isEmpty ? demoSupplierName : name;
  }

  ProductModel? productForOffer(SupplierOfferModel offer) {
    return _repository.findProduct(offer.productId);
  }

  void _start(SupplierStarted event, Emitter<SupplierState> emit) {
    _emitOffers(emit, status: LoadStatus.success);
  }

  Future<void> _stats(
    SupplierStatsRequested event,
    Emitter<SupplierState> emit,
  ) async {
    if (!AppEnv.useRemote) {
      _emitOffers(emit, status: LoadStatus.success);
      return;
    }
    final cached = _remote.cachedProducts(supplierName);
    if (cached != null) _repository.replaceOwn(cached.$1, cached.$2);
    emit(
      state.copyWith(
        offers: _repository.ownOffers(supplierName),
        stats: _remote.cachedStats(),
        status: cached == null ? LoadStatus.loading : LoadStatus.success,
        errorMessage: '',
        revision: state.revision + 1,
      ),
    );
    try {
      final own = await _remote.ownProducts(supplierName);
      _repository.replaceOwn(own.$1, own.$2);
      emit(
        state.copyWith(
          offers: _repository.ownOffers(supplierName),
          status: LoadStatus.success,
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
    try {
      final stats = await _remote.stats();
      emit(state.copyWith(stats: stats, revision: state.revision + 1));
    } on Object catch (error) {
      AppLogger.log('SupplierBloc: stats failed $error');
    }
    try {
      final categories = await _remote.categories();
      emit(
        state.copyWith(categories: categories, revision: state.revision + 1),
      );
    } on Object catch (error) {
      AppLogger.log('SupplierBloc: categories failed $error');
    }
  }

  void _shell(SupplierShellSelected event, Emitter<SupplierState> emit) {
    emit(state.copyWith(shellIndex: event.index, revision: state.revision + 1));
  }

  void _search(SupplierSearchChanged event, Emitter<SupplierState> emit) {
    emit(
      state.copyWith(
        searchQuery: event.query,
        searchResults: _repository.searchProducts(event.query),
        revision: state.revision + 1,
      ),
    );
  }

  void _select(SupplierProductSelected event, Emitter<SupplierState> emit) {
    emit(
      state.copyWith(
        selectedProduct: event.product,
        closePage: false,
        errorMessage: '',
        revision: state.revision + 1,
      ),
    );
  }

  void _clear(SupplierSelectionCleared event, Emitter<SupplierState> emit) {
    emit(
      state.copyWith(
        clearProduct: true,
        searchQuery: '',
        searchResults: const [],
        closePage: false,
        errorMessage: '',
        revision: state.revision + 1,
      ),
    );
  }

  void _feedback(SupplierFeedbackCleared event, Emitter<SupplierState> emit) {
    emit(
      state.copyWith(
        closePage: false,
        errorMessage: '',
        saving: false,
        revision: state.revision + 1,
      ),
    );
  }

  void _create(
    SupplierProductCreateRequested event,
    Emitter<SupplierState> emit,
  ) {
    AppLogger.log('SupplierBloc: SupplierProductCreateRequested');
    try {
      final created = _repository.createMasterProduct(
        ProductModel(
          id: 'product-${DateTime.now().microsecondsSinceEpoch}',
          name: event.name.trim(),
          category: event.category.trim(),
          categoryId: event.categoryId,
          manufacturer: event.manufacturer.trim(),
          reference: event.reference.trim(),
          packSize: event.packSize.trim(),
          imageAsset: '',
          imageBytes: event.imageBytes,
          brand: event.brand.trim(),
          specifications: event.specifications.trim(),
          barcode: event.barcode.trim(),
          countryOfOrigin: event.countryOfOrigin.trim(),
          storageRequirements: event.storageRequirements.trim(),
          documentName: event.documentName.trim(),
          sfdaCode: event.sfdaCode.trim(),
        ),
      );
      emit(
        state.copyWith(
          selectedProduct: created,
          errorMessage: '',
          closePage: false,
          revision: state.revision + 1,
        ),
      );
    } on DuplicateProductException {
      emit(
        state.copyWith(
          errorMessage: AppLocale.translate('duplicate_product'),
          closePage: false,
          revision: state.revision + 1,
        ),
      );
    }
  }

  Future<void> _save(
    SupplierOfferSaveRequested event,
    Emitter<SupplierState> emit,
  ) async {
    AppLogger.log('SupplierBloc: SupplierOfferSaveRequested');
    var offer = SupplierOfferModel(
      id:
          event.existing?.id ??
          'offer-${DateTime.now().microsecondsSinceEpoch}',
      productId: event.product.id,
      supplierName: supplierName,
      price: event.discountPrice ?? event.price,
      stock: event.stock,
      description: event.description.trim(),
      minimumOrder: event.minimumOrder,
      preparationDays: event.preparationDays,
      listPrice: event.discountPrice == null ? null : event.price,
      unitCost: event.unitCost,
    );
    if (AppEnv.useRemote) {
      emit(
        state.copyWith(
          saving: true,
          errorMessage: '',
          revision: state.revision + 1,
        ),
      );
      try {
        if (event.existing == null) {
          final categoryId = event.product.categoryId.isNotEmpty
              ? event.product.categoryId
              : (state.categories.isEmpty ? '' : state.categories.first.id);
          if (categoryId.isEmpty) {
            throw StateError(AppLocale.translate('no_categories'));
          }
          final created = await _remote.createProduct(
            _productBody(event.product, offer, categoryId),
          );
          final product = created == null
              ? null
              : ProductModel.tryParse(created);
          if (product != null) {
            _repository.replaceProductId(event.product.id, product);
            offer =
                SupplierOfferModel.fromProductRow(
                  created!,
                  product,
                  fallbackSupplier: supplierName,
                ) ??
                offer;
          }
        } else {
          await _remote.updateProduct(offer.id, {
            ..._priceBody(offer, clearDiscount: event.existing!.discounted),
            'stockQuantity': offer.stock,
            'minOrderQuantity': offer.minimumOrder,
            if (offer.description.isNotEmpty)
              'fullDescription': offer.description,
          });
        }
      } on Object catch (error) {
        emit(
          state.copyWith(
            saving: false,
            errorMessage: ApiError.message(error),
            revision: state.revision + 1,
          ),
        );
        return;
      }
    }
    _repository.saveOffer(offer);
    _catalog.add(const CatalogRefreshRequested());
    _emitOffers(emit, closePage: true);
  }

  Future<void> _adjust(
    SupplierStockAdjusted event,
    Emitter<SupplierState> emit,
  ) async {
    final delta = event.newStock - event.offer.stock;
    if (delta != 0 && AppEnv.useRemote) {
      emit(
        state.copyWith(
          saving: true,
          errorMessage: '',
          revision: state.revision + 1,
        ),
      );
      try {
        await _remote.adjustStock(
          event.offer.id,
          adjustment: delta,
          reason: event.reason,
          notes: event.notes,
        );
      } on Object catch (error) {
        emit(
          state.copyWith(
            saving: false,
            errorMessage: ApiError.message(error),
            revision: state.revision + 1,
          ),
        );
        return;
      }
    }
    _repository.saveOffer(event.offer.copyWith(stock: event.newStock));
    _catalog.add(const CatalogRefreshRequested());
    _emitOffers(emit, closePage: true);
  }

  Future<void> _delete(
    SupplierOfferDeleteRequested event,
    Emitter<SupplierState> emit,
  ) async {
    AppLogger.log('SupplierBloc: SupplierOfferDeleteRequested');
    if (AppEnv.useRemote) {
      try {
        await _remote.deleteProduct(event.id);
      } on Object catch (error) {
        emit(
          state.copyWith(
            errorMessage: ApiError.message(error),
            revision: state.revision + 1,
          ),
        );
        return;
      }
    }
    _repository.deleteOffer(event.id);
    _catalog.add(const CatalogRefreshRequested());
    _emitOffers(emit);
  }

  Map<String, Object?> _priceBody(
    SupplierOfferModel offer, {
    bool clearDiscount = false,
  }) {
    final unitCost = offer.unitCost;
    return {
      'sellingPrice': offer.sellingPrice,
      if (offer.discounted)
        'discountPrice': offer.price
      else if (clearDiscount)
        'discountPrice': null,
      'unitCostPrice': ?unitCost,
    };
  }

  Map<String, Object?> _productBody(
    ProductModel product,
    SupplierOfferModel offer,
    String categoryId,
  ) {
    String orDash(String value) => value.trim().isEmpty ? '-' : value.trim();
    return {
      'categoryId': categoryId,
      'name': product.name,
      'brandName': orDash(product.brand),
      'modelSku': orDash(product.reference),
      'unitType': orDash(product.packSize),
      'countryOfOrigin': orDash(product.countryOfOrigin),
      'shortDescription': orDash(product.specifications),
      if (offer.description.isNotEmpty) 'fullDescription': offer.description,
      if (product.sfdaCode.isNotEmpty) 'sfdaCode': product.sfdaCode,
      ..._priceBody(offer),
      'stockQuantity': offer.stock,
      'minOrderQuantity': offer.minimumOrder,
      'status': 'ACTIVE',
    };
  }

  void _emitOffers(
    Emitter<SupplierState> emit, {
    LoadStatus? status,
    bool closePage = false,
  }) {
    emit(
      state.copyWith(
        offers: _repository.ownOffers(supplierName),
        status: status,
        closePage: closePage,
        saving: false,
        errorMessage: '',
        revision: state.revision + 1,
      ),
    );
  }
}
