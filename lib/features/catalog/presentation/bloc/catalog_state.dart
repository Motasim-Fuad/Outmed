import 'package:equatable/equatable.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';

class CatalogState extends Equatable {
  const CatalogState({
    this.products = const [],
    this.offers = const [],
    this.searchQuery = '',
    this.status = LoadStatus.initial,
    this.errorMessage = '',
    this.revision = 0,
  });

  final List<ProductModel> products;
  final List<SupplierOfferModel> offers;
  final String searchQuery;
  final LoadStatus status;
  final String errorMessage;
  final int revision;

  bool get loading => status == LoadStatus.loading && products.isEmpty;

  List<ProductModel> get visibleProducts {
    final query = searchQuery.trim().toLowerCase();
    return products
        .where(
          (product) => query.isEmpty || product.searchableText.contains(query),
        )
        .toList(growable: false);
  }

  List<ProductModel> get featured {
    final visible = visibleProducts;
    final marked = visible.where((product) => product.featured).toList();
    return marked.isEmpty ? visible : marked;
  }

  List<SupplierOfferModel> offersFor(String productId) {
    return offers
        .where((offer) => offer.productId == productId)
        .toList(growable: false)
      ..sort((a, b) => a.price.compareTo(b.price));
  }

  SupplierOfferModel? bestOfferFor(String productId) {
    final matches = offersFor(productId);
    return matches.isEmpty ? null : matches.first;
  }

  ProductModel? productById(String id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  SupplierOfferModel? offerById(String id) {
    for (final offer in offers) {
      if (offer.id == id) return offer;
    }
    return null;
  }

  CatalogState copyWith({
    List<ProductModel>? products,
    List<SupplierOfferModel>? offers,
    String? searchQuery,
    LoadStatus? status,
    String? errorMessage,
    int? revision,
  }) {
    return CatalogState(
      products: products ?? this.products,
      offers: offers ?? this.offers,
      searchQuery: searchQuery ?? this.searchQuery,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      revision: revision ?? this.revision,
    );
  }

  @override
  List<Object?> get props => [revision, status, searchQuery, errorMessage];
}
