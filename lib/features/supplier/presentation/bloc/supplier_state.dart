import 'package:equatable/equatable.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/supplier/data/models/category_option.dart';
import 'package:outmed/features/supplier/data/models/supplier_stats.dart';

class SupplierState extends Equatable {
  const SupplierState({
    this.offers = const [],
    this.searchResults = const [],
    this.searchQuery = '',
    this.selectedProduct,
    this.shellIndex = 0,
    this.status = LoadStatus.initial,
    this.errorMessage = '',
    this.closePage = false,
    this.saving = false,
    this.stats = const SupplierStats(),
    this.categories = const [],
    this.revision = 0,
  });

  final List<SupplierOfferModel> offers;
  final List<ProductModel> searchResults;
  final String searchQuery;
  final ProductModel? selectedProduct;
  final int shellIndex;
  final LoadStatus status;
  final String errorMessage;
  final bool closePage;
  final bool saving;
  final SupplierStats stats;
  final List<CategoryOption> categories;
  final int revision;

  bool get loading => status == LoadStatus.loading;

  SupplierState copyWith({
    List<SupplierOfferModel>? offers,
    List<ProductModel>? searchResults,
    String? searchQuery,
    ProductModel? selectedProduct,
    bool clearProduct = false,
    int? shellIndex,
    LoadStatus? status,
    String? errorMessage,
    bool? closePage,
    bool? saving,
    SupplierStats? stats,
    List<CategoryOption>? categories,
    int? revision,
  }) {
    return SupplierState(
      offers: offers ?? this.offers,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedProduct: clearProduct
          ? null
          : selectedProduct ?? this.selectedProduct,
      shellIndex: shellIndex ?? this.shellIndex,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      closePage: closePage ?? this.closePage,
      saving: saving ?? this.saving,
      stats: stats ?? this.stats,
      categories: categories ?? this.categories,
      revision: revision ?? this.revision,
    );
  }

  @override
  List<Object?> get props => [
    revision,
    shellIndex,
    status,
    errorMessage,
    closePage,
    saving,
    stats,
    categories,
  ];
}
