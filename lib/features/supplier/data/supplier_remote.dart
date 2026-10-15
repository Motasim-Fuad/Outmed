import 'package:outmed/core/network/api_endpoints.dart';
import 'package:outmed/core/network/api_json.dart';
import 'package:outmed/core/network/offline_queue.dart';
import 'package:outmed/core/network/remote_cache.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/supplier/data/models/category_option.dart';
import 'package:outmed/features/supplier/data/models/supplier_stats.dart';

class SupplierRemote {
  const SupplierRemote(this._cache, this._queue);

  static const _ownQuery = {'page': 1, 'limit': 100};

  final RemoteCache _cache;
  final OfflineQueue _queue;

  (List<ProductModel>, List<SupplierOfferModel>)? cachedProducts(
    String supplierName,
  ) {
    final body = _cache.peek(ApiEndpoints.supplierProducts, query: _ownQuery);
    if (body == null) return null;
    return _parseProducts(body, supplierName);
  }

  Future<(List<ProductModel>, List<SupplierOfferModel>)> ownProducts(
    String supplierName,
  ) async {
    final body = await _cache.get(
      ApiEndpoints.supplierProducts,
      query: _ownQuery,
    );
    return _parseProducts(body, supplierName);
  }

  SupplierStats? cachedStats() {
    final body = _cache.peek(ApiEndpoints.supplierStats);
    return body == null ? null : SupplierStats.parse(body);
  }

  Future<SupplierStats> stats() async {
    return SupplierStats.parse(await _cache.get(ApiEndpoints.supplierStats));
  }

  Future<List<CategoryOption>> categories() async {
    final body = await _cache.get(ApiEndpoints.categories);
    return ApiJson.maps(
          body,
        )
        .map(CategoryOption.tryParse)
        .whereType<CategoryOption>()
        .toList(
          growable: false,
        );
  }

  Future<Map<String, Object?>?> createProduct(Map<String, Object?> body) async {
    final response = await _queue.send(
      'POST',
      ApiEndpoints.supplierProducts,
      body: body,
    );
    return ApiJson.asMap(ApiJson.unwrap(response));
  }

  Future<void> updateProduct(String id, Map<String, Object?> body) async {
    await _queue.send('PATCH', ApiEndpoints.supplierProduct(id), body: body);
  }

  Future<void> deleteProduct(String id) async {
    await _queue.send('DELETE', ApiEndpoints.supplierProduct(id));
  }

  Future<void> adjustStock(
    String id, {
    required int adjustment,
    required String reason,
    String notes = '',
  }) async {
    await _queue.send(
      'POST',
      ApiEndpoints.supplierStock(id),
      body: {
        'adjustment': adjustment,
        'reason': reason,
        if (notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );
  }

  (List<ProductModel>, List<SupplierOfferModel>) _parseProducts(
    Object? body,
    String supplierName,
  ) {
    final products = <ProductModel>[];
    final offers = <SupplierOfferModel>[];
    for (final row in ApiJson.maps(body)) {
      final product = ProductModel.tryParse(row);
      if (product == null) continue;
      products.add(product);
      final offer = SupplierOfferModel.fromProductRow(
        row,
        product,
        fallbackSupplier: supplierName,
      );
      if (offer != null) offers.add(offer);
    }
    return (products, offers);
  }
}
