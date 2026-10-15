import 'package:equatable/equatable.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/catalog/data/models/marketplace_supplier.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';

class SupplierDirectoryState extends Equatable {
  const SupplierDirectoryState({
    this.suppliers = MarketplaceSupplier.all,
    this.top = MarketplaceSupplier.all,
    this.details = const {},
    this.query = '',
    this.status = LoadStatus.initial,
    this.detailStatus = LoadStatus.initial,
    this.errorMessage = '',
  });

  final List<MarketplaceSupplier> suppliers;
  final List<MarketplaceSupplier> top;
  final Map<String, MarketplaceSupplier> details;
  final String query;
  final LoadStatus status;
  final LoadStatus detailStatus;
  final String errorMessage;

  bool get loading => status == LoadStatus.loading;

  List<MarketplaceSupplier> get visible {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return suppliers;
    return suppliers
        .where((supplier) => supplier.name.toLowerCase().contains(text))
        .toList(growable: false);
  }

  MarketplaceSupplier byName(String name) {
    for (final supplier in [...suppliers, ...top]) {
      if (supplier.name == name) return supplier;
    }
    if (AppEnv.useRemote) {
      return MarketplaceSupplier(
        name: name,
        logo: '',
        rating: '-',
        reviews: '0',
        years: '-',
        productsCount: '-',
      );
    }
    return MarketplaceSupplier.byName(name);
  }

  MarketplaceSupplier forProduct(ProductModel product, String supplierName) {
    for (final supplier in [...suppliers, ...top]) {
      if (product.supplierId.isNotEmpty && supplier.id == product.supplierId) {
        return supplier;
      }
      if (supplier.name == supplierName) return supplier;
    }
    if (product.supplierId.isEmpty) return byName(supplierName);
    return MarketplaceSupplier(
      id: product.supplierId,
      userId: product.supplierUserId,
      name: supplierName,
      logo: '',
      rating: '-',
      reviews: '0',
      years: '-',
      productsCount: '-',
    );
  }

  MarketplaceSupplier resolve(MarketplaceSupplier supplier) {
    return details[supplier.id] ?? supplier;
  }

  SupplierDirectoryState copyWith({
    List<MarketplaceSupplier>? suppliers,
    List<MarketplaceSupplier>? top,
    Map<String, MarketplaceSupplier>? details,
    String? query,
    LoadStatus? status,
    LoadStatus? detailStatus,
    String? errorMessage,
  }) {
    return SupplierDirectoryState(
      suppliers: suppliers ?? this.suppliers,
      top: top ?? this.top,
      details: details ?? this.details,
      query: query ?? this.query,
      status: status ?? this.status,
      detailStatus: detailStatus ?? this.detailStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    suppliers,
    top,
    details,
    query,
    status,
    detailStatus,
    errorMessage,
  ];
}
