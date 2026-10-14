import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/constants/app_assets.dart';
import 'package:outmed/core/constants/app_durations.dart';
import 'package:outmed/core/l10n/app_locale.dart';
import 'package:outmed/core/logger/app_logger.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_event.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_event.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_state.dart';

class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  SupplierBloc(this._repository, this._catalog) : super(const SupplierState()) {
    on<SupplierStarted>(_start);
    on<SupplierShellSelected>(_shell);
    on<SupplierSearchChanged>(_search);
    on<SupplierProductSelected>(_select);
    on<SupplierSelectionCleared>(_clear);
    on<SupplierProductCreateRequested>(_create);
    on<SupplierOfferSaveRequested>(_save);
    on<SupplierOfferDeleteRequested>(_delete);
    add(const SupplierStarted());
  }

  final CatalogRepository _repository;
  final CatalogBloc _catalog;

  static const supplierName = 'HealthCare Supplies';

  ProductModel? productForOffer(SupplierOfferModel offer) {
    return _repository.findProduct(offer.productId);
  }

  Future<void> _start(SupplierStarted event, Emitter<SupplierState> emit) async {
    emit(state.copyWith(status: LoadStatus.loading, revision: state.revision + 1));
    if (!AppEnv.isTest) {
      await Future<void>.delayed(AppDurations.shimmer);
    }
    _emitOffers(emit, status: LoadStatus.success);
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
        revision: state.revision + 1,
      ),
    );
  }

  void _create(SupplierProductCreateRequested event, Emitter<SupplierState> emit) {
    AppLogger.log('SupplierBloc: SupplierProductCreateRequested');
    try {
      final created = _repository.createMasterProduct(
        ProductModel(
          id: 'product-${DateTime.now().microsecondsSinceEpoch}',
          name: event.name.trim(),
          category: event.category.trim(),
          manufacturer: event.manufacturer.trim(),
          reference: event.reference.trim(),
          packSize: event.packSize.trim(),
          imageAsset: AppAssets.diagnosticKit,
          imageBytes: event.imageBytes,
          brand: event.brand.trim(),
          specifications: event.specifications.trim(),
          barcode: event.barcode.trim(),
          countryOfOrigin: event.countryOfOrigin.trim(),
          storageRequirements: event.storageRequirements.trim(),
          documentName: event.documentName.trim(),
        ),
      );
      _catalog.add(const CatalogRefreshRequested());
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

  void _save(SupplierOfferSaveRequested event, Emitter<SupplierState> emit) {
    AppLogger.log('SupplierBloc: SupplierOfferSaveRequested');
    _repository.saveOffer(
      SupplierOfferModel(
        id: event.existing?.id ?? 'offer-${DateTime.now().microsecondsSinceEpoch}',
        productId: event.product.id,
        supplierName: supplierName,
        price: event.price,
        stock: event.stock,
        description: event.description.trim(),
        minimumOrder: event.minimumOrder,
        preparationDays: event.preparationDays,
      ),
    );
    _catalog.add(const CatalogRefreshRequested());
    _emitOffers(emit, closePage: true);
  }

  void _delete(SupplierOfferDeleteRequested event, Emitter<SupplierState> emit) {
    AppLogger.log('SupplierBloc: SupplierOfferDeleteRequested');
    _repository.deleteOffer(event.id);
    _catalog.add(const CatalogRefreshRequested());
    _emitOffers(emit);
  }

  void _emitOffers(Emitter<SupplierState> emit, {LoadStatus? status, bool closePage = false}) {
    emit(
      state.copyWith(
        offers: _repository.getOffers().where((offer) => offer.supplierName == supplierName).toList(),
        status: status,
        closePage: closePage,
        errorMessage: '',
        revision: state.revision + 1,
      ),
    );
  }
}
