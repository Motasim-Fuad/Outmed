import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/constants/app_assets.dart';
import 'package:outmed/core/logger/app_logger.dart';
import 'package:outmed/core/network/api_endpoints.dart';
import 'package:outmed/core/network/api_json.dart';
import 'package:outmed/core/network/remote_cache.dart';
import 'package:outmed/core/storage/app_database.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/catalog/domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._cache)
    : _products = AppEnv.useRemote
          ? []
          : [
              const ProductModel(
                id: 'diagnostic-kit',
                name: 'Clinical Diagnostic Kit',
                category: 'Diagnostic',
                manufacturer: 'OutMed Medical',
                reference: 'OM-DK-100',
                packSize: '1 complete kit',
                imageAsset: AppAssets.diagnosticKit,
              ),
              const ProductModel(
                id: 'syringe-5ml',
                name: 'Disposable Syringe 5ml',
                category: 'Surgical',
                manufacturer: 'MedCare',
                reference: 'MC-SY-5',
                packSize: 'Box of 100',
                imageAsset: AppAssets.syringe,
                addedOn: '12 Aug 2026',
              ),
              const ProductModel(
                id: 'examination-set',
                name: 'Nitrile Examination Gloves (M)',
                category: 'PPE & Safety',
                manufacturer: 'HealthPlus',
                reference: 'HP-EX-20',
                packSize: 'Box of 20',
                imageAsset: AppAssets.catalogIllustration,
                addedOn: '08 Aug 2026',
              ),
              const ProductModel(
                id: 'hospital-supply-pack',
                name: 'Hospital Supply Pack',
                category: 'Diagnostic',
                manufacturer: 'Marsh Medical',
                reference: 'MM-HS-50',
                packSize: 'Pack of 50',
                imageAsset: AppAssets.orderIllustration,
                addedOn: '05 Aug 2026',
              ),
              const ProductModel(
                id: 'surgical-mask',
                name: '3-Ply Surgical Face Mask',
                category: 'PPE & Safety',
                manufacturer: 'HealthPlus',
                reference: 'HP-MSK-50',
                packSize: 'Box of 50',
                imageAsset: AppAssets.deliveryIllustration,
                addedOn: '02 Aug 2026',
              ),
            ],
      _offers = AppEnv.useRemote
          ? []
          : [
              const SupplierOfferModel(
                id: 'offer-1',
                productId: 'diagnostic-kit',
                supplierName: 'HealthCare Supplies',
                price: 145,
                stock: 84,
                description: 'Complete diagnostic kit with fast dispatch.',
              ),
              const SupplierOfferModel(
                id: 'offer-2',
                productId: 'diagnostic-kit',
                supplierName: 'Shifaa Care Guide',
                price: 148,
                stock: 42,
                description: 'Verified original equipment with warranty.',
                preparationDays: 3,
              ),
              const SupplierOfferModel(
                id: 'offer-3',
                productId: 'diagnostic-kit',
                supplierName: 'Nabir Medical',
                price: 150,
                stock: 120,
                description: 'Bulk quantities available.',
                minimumOrder: 5,
              ),
              const SupplierOfferModel(
                id: 'offer-4',
                productId: 'syringe-5ml',
                supplierName: 'HealthCare Supplies',
                price: 32,
                stock: 10,
                description: 'Sterile single-use syringes.',
              ),
              const SupplierOfferModel(
                id: 'offer-5',
                productId: 'examination-set',
                supplierName: 'HealthCare Supplies',
                price: 45,
                stock: 18,
                description: 'Essential examination supplies.',
              ),
              const SupplierOfferModel(
                id: 'offer-6',
                productId: 'hospital-supply-pack',
                supplierName: 'Marsh Medical',
                price: 220,
                stock: 65,
                description: 'Prepared hospital consumables pack.',
              ),
              const SupplierOfferModel(
                id: 'offer-7',
                productId: 'surgical-mask',
                supplierName: 'HealthCare Supplies',
                price: 28,
                stock: 0,
                description: '3-ply surgical masks for clinical use.',
              ),
            ];

  final RemoteCache _cache;
  final List<ProductModel> _products;
  final List<SupplierOfferModel> _offers;
  List<SupplierOfferModel>? _own;
  final Map<String, Uint8List> _images = {};
  AppDatabase? _local;

  ProductModel _withLocalImage(ProductModel product) {
    if (product.imageBytes != null || product.imageAsset.startsWith('http')) {
      return product;
    }
    final bytes = _images[product.id];
    return bytes == null ? product : product.withImageBytes(bytes);
  }

  @override
  List<ProductModel> getProducts() => List.unmodifiable(_products);

  @override
  List<SupplierOfferModel> getOffers() => List.unmodifiable(_offers);

  @override
  ProductModel? findProduct(String productId) {
    for (final product in _products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  @override
  List<ProductModel> searchProducts(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return getProducts();
    return _products
        .where((product) => product.searchableText.contains(normalized))
        .toList(growable: false);
  }

  @override
  bool productExists({required String name, required String reference}) {
    final normalizedName = name.trim().toLowerCase();
    final normalizedReference = reference.trim().toLowerCase();
    return _products.any(
      (product) =>
          product.name.trim().toLowerCase() == normalizedName ||
          product.reference.trim().toLowerCase() == normalizedReference,
    );
  }

  @override
  ProductModel createMasterProduct(ProductModel product) {
    if (productExists(name: product.name, reference: product.reference)) {
      throw const DuplicateProductException();
    }
    final bytes = product.imageBytes;
    if (bytes != null) _images[product.id] = bytes;
    _products.add(product);
    _persist();
    return product;
  }

  @override
  SupplierOfferModel saveOffer(SupplierOfferModel offer) {
    final index = _offers.indexWhere((item) => item.id == offer.id);
    if (index >= 0) {
      _offers[index] = offer;
    } else {
      _offers.add(offer);
    }
    final own = _own;
    if (own != null) {
      final ownIndex = own.indexWhere((item) => item.id == offer.id);
      if (ownIndex >= 0) {
        own[ownIndex] = offer;
      } else {
        own.add(offer);
      }
    }
    _persist();
    return offer;
  }

  @override
  bool deleteOffer(String id) {
    final index = _offers.indexWhere((item) => item.id == id);
    _own?.removeWhere((item) => item.id == id);
    if (index < 0) return false;
    _offers.removeAt(index);
    _persist();
    return true;
  }

  @override
  List<SupplierOfferModel> ownOffers(String supplierName) {
    final own = _own;
    if (own != null) return List.unmodifiable(own);
    return _offers
        .where((offer) => offer.supplierName == supplierName)
        .toList(growable: false);
  }

  @override
  void replaceOwn(
    List<ProductModel> products,
    List<SupplierOfferModel> offers,
  ) {
    for (final raw in products) {
      final product = _withLocalImage(raw);
      final index = _products.indexWhere((item) => item.id == product.id);
      if (index >= 0) {
        _products[index] = product;
      } else {
        _products.add(product);
      }
    }
    _own = [...offers];
    _persist();
  }

  @override
  void replaceProductId(String oldId, ProductModel product) {
    final bytes = _images.remove(oldId);
    if (bytes != null) _images[product.id] = bytes;
    _products
      ..removeWhere((item) => item.id == oldId || item.id == product.id)
      ..add(_withLocalImage(product));
    _persist();
  }

  Future<void> bindLocal(AppDatabase database) async {
    _local = database;
    for (final row in await database.readBucket('product_images')) {
      final id = row['id'];
      final data = row['data'];
      if (id is String && data is String) _images[id] = base64Decode(data);
    }
    final products = await database.readBucket('products');
    final offers = await database.readBucket('offers');
    if (products.isNotEmpty) {
      _products
        ..clear()
        ..addAll(products.map(ProductModel.fromJson).map(_withLocalImage));
    }
    if (offers.isNotEmpty) {
      _offers
        ..clear()
        ..addAll(offers.map(SupplierOfferModel.fromJson));
    }
    final own = await database.readBucket('own_offers');
    if (own.isNotEmpty) _own = own.map(SupplierOfferModel.fromJson).toList();
  }

  void _persist() {
    final database = _local;
    if (database == null) return;
    unawaited(
      database.writeBucket('products', {
        for (final item in _products) item.id: item.toJson(),
      }),
    );
    unawaited(
      database.writeBucket('product_images', {
        for (final entry in _images.entries)
          entry.key: {'id': entry.key, 'data': base64Encode(entry.value)},
      }),
    );
    unawaited(
      database.writeBucket('offers', {
        for (final item in _offers) item.id: item.toJson(),
      }),
    );
    final own = _own;
    if (own != null) {
      unawaited(
        database.writeBucket('own_offers', {
          for (final item in own) item.id: item.toJson(),
        }),
      );
    }
  }

  @override
  Future<void> refreshRemote() async {
    if (!AppEnv.useRemote) return;
    final body = await _cache.get(
      ApiEndpoints.products,
      query: const {'page': 1, 'limit': 100},
    );
    final rows = ApiJson.maps(body);
    try {
      final featured = await _cache.get(ApiEndpoints.featuredProducts);
      for (final row in ApiJson.maps(featured)) {
        final id = ApiJson.text(row, const ['id']);
        rows
          ..removeWhere((item) => ApiJson.text(item, const ['id']) == id)
          ..add({...row, 'isFeatured': true});
      }
    } on Object catch (error) {
      AppLogger.log('Catalog: featured failed $error');
    }
    final products = <ProductModel>[];
    final offers = <SupplierOfferModel>[];
    for (final row in rows) {
      final product = ProductModel.tryParse(row);
      if (product == null) continue;
      products.add(_withLocalImage(product));
      final offer = SupplierOfferModel.fromProductRow(row, product);
      if (offer != null) offers.add(offer);
    }
    _products
      ..clear()
      ..addAll(products);
    _offers
      ..clear()
      ..addAll(offers);
    _persist();
  }

  @override
  Future<void> refreshProduct(String productId) async {
    if (!AppEnv.useRemote) return;
    final current = findProduct(productId);
    if (current == null) return;
    final key = current.slug.isNotEmpty ? current.slug : current.id;
    final body = await _cache.get(ApiEndpoints.product(key));
    final row = ApiJson.asMap(ApiJson.unwrap(body));
    if (row == null) return;
    final parsed = ProductModel.tryParse({
      ...row,
      if (current.featured) 'isFeatured': true,
    });
    if (parsed == null) return;
    final index = _products.indexWhere((item) => item.id == productId);
    if (index >= 0) _products[index] = _withLocalImage(parsed);
    final offer = SupplierOfferModel.fromProductRow(row, parsed);
    if (offer != null) {
      _offers
        ..removeWhere((item) => item.productId == productId)
        ..add(offer);
    }
    _persist();
  }
}
