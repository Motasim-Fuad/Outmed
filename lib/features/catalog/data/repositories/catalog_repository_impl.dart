import 'dart:async';

import 'package:dio/dio.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/constants/app_assets.dart';
import 'package:outmed/core/logger/app_logger.dart';
import 'package:outmed/core/network/api_endpoints.dart';
import 'package:outmed/core/storage/app_database.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/catalog/domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._dio)
    : _products = [
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
      _offers = [
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

  final Dio _dio;
  final List<ProductModel> _products;
  final List<SupplierOfferModel> _offers;
  AppDatabase? _local;

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
    _persist();
    return offer;
  }

  @override
  bool deleteOffer(String id) {
    final index = _offers.indexWhere((item) => item.id == id);
    if (index < 0) return false;
    _offers.removeAt(index);
    _persist();
    return true;
  }

  Future<void> bindLocal(AppDatabase database) async {
    _local = database;
    final products = await database.readBucket('products');
    final offers = await database.readBucket('offers');
    if (products.isNotEmpty) {
      _products
        ..clear()
        ..addAll(products.map(ProductModel.fromJson));
    }
    if (offers.isNotEmpty) {
      _offers
        ..clear()
        ..addAll(offers.map(SupplierOfferModel.fromJson));
    }
  }

  void _persist() {
    final database = _local;
    if (database == null) return;
    unawaited(database.writeBucket('products', {for (final item in _products) item.id: item.toJson()}));
    unawaited(database.writeBucket('offers', {for (final item in _offers) item.id: item.toJson()}));
  }

  @override
  Future<void> refreshRemote() async {
    if (AppEnv.isMock || AppEnv.isTest) return;
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.products);
      AppLogger.log('CatalogRepository: remote status ${response.statusCode}');
    } on DioException catch (error) {
      AppLogger.log('CatalogRepository: remote skipped ${error.type.name}');
    }
  }
}
