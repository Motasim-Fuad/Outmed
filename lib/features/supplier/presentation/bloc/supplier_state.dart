import 'package:equatable/equatable.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';

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
  final int revision;

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
    int? revision,
  }) {
    return SupplierState(
      offers: offers ?? this.offers,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedProduct: clearProduct ? null : selectedProduct ?? this.selectedProduct,
      shellIndex: shellIndex ?? this.shellIndex,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      closePage: closePage ?? this.closePage,
      revision: revision ?? this.revision,
    );
  }

  @override
  List<Object?> get props => [revision, shellIndex, status, errorMessage, closePage];
}
