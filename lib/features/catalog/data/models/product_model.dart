import 'dart:typed_data';

import 'package:outmed/core/constants/app_assets.dart';
import 'package:outmed/core/network/api_json.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.manufacturer,
    required this.reference,
    required this.packSize,
    required this.imageAsset,
    this.imageBytes,
    this.brand = '',
    this.specifications = '',
    this.barcode = '',
    this.countryOfOrigin = '',
    this.storageRequirements = '',
    this.documentName = '',
    this.addedOn = '10 Aug 2026',
    this.supplierId = '',
    this.supplierUserId = '',
    this.categoryId = '',
  });

  factory ProductModel.fromJson(Map<String, Object?> json) {
    return ProductModel(
      id: json['id']! as String,
      name: json['name']! as String,
      category: json['category']! as String,
      manufacturer: json['manufacturer']! as String,
      reference: json['reference']! as String,
      packSize: json['packSize']! as String,
      imageAsset: json['imageAsset']! as String,
      brand: json['brand'] as String? ?? '',
      specifications: json['specifications'] as String? ?? '',
      barcode: json['barcode'] as String? ?? '',
      countryOfOrigin: json['countryOfOrigin'] as String? ?? '',
      storageRequirements: json['storageRequirements'] as String? ?? '',
      documentName: json['documentName'] as String? ?? '',
      addedOn: json['addedOn'] as String? ?? '',
      supplierId: json['supplierId'] as String? ?? '',
      supplierUserId: json['supplierUserId'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
    );
  }

  final String id;
  final String name;
  final String category;
  final String manufacturer;
  final String reference;
  final String packSize;
  final String imageAsset;
  final Uint8List? imageBytes;
  final String brand;
  final String specifications;
  final String barcode;
  final String countryOfOrigin;
  final String storageRequirements;
  final String documentName;
  final String addedOn;
  final String supplierId;
  final String supplierUserId;
  final String categoryId;

  String get searchableText =>
      '$name $category $brand $manufacturer $reference $barcode'.toLowerCase();

  static ProductModel? tryParse(Map<String, Object?> json) {
    final id = ApiJson.text(json, const ['id', 'product_id', 'slug']);
    final name = ApiJson.text(json, const ['name', 'title']);
    if (id == null || name == null) return null;
    return ProductModel(
      id: id,
      name: name,
      category: _categoryName(json),
      manufacturer: ApiJson.text(json, const ['manufacturer']) ?? '',
      reference:
          ApiJson.text(json, const ['modelSku', 'reference', 'sku']) ?? '',
      packSize:
          ApiJson.text(json, const ['unitType', 'pack_size', 'packSize']) ?? '',
      imageAsset: _image(json),
      brand:
          ApiJson.text(json, const ['brandName', 'brand']) ??
          supplierNameOf(json),
      specifications:
          ApiJson.text(json, const [
            'specifications',
            'specification',
            'shortDescription',
          ]) ??
          '',
      barcode: ApiJson.text(json, const ['barcode', 'udi']) ?? '',
      countryOfOrigin:
          ApiJson.text(json, const ['country_of_origin', 'countryOfOrigin']) ??
          '',
      storageRequirements:
          ApiJson.text(json, const [
            'storage_requirements',
            'storageRequirements',
          ]) ??
          '',
      documentName:
          ApiJson.text(json, const ['document_name', 'documentName']) ?? '',
      addedOn:
          ApiJson.text(json, const ['added_on', 'addedOn', 'createdAt']) ?? '',
      supplierId: _supplierField(json, const ['supplierId'], const ['id']),
      supplierUserId: _supplierField(
        json,
        const ['supplierUserId'],
        const ['userId'],
      ),
      categoryId:
          ApiJson.text(json, const ['categoryId']) ??
          ApiJson.text(
            ApiJson.asMap(json['category']) ?? const {},
            const ['id'],
          ) ??
          '',
    );
  }

  static String _supplierField(
    Map<String, Object?> json,
    List<String> direct,
    List<String> nested,
  ) {
    final value = ApiJson.text(json, direct);
    if (value != null) return value;
    final supplier = ApiJson.asMap(json['supplier']);
    if (supplier == null) return '';
    final user = ApiJson.asMap(supplier['user']);
    return ApiJson.text(supplier, nested) ??
        (user == null ? null : ApiJson.text(user, const ['id'])) ??
        '';
  }

  static String _categoryName(Map<String, Object?> json) {
    final direct = ApiJson.text(json, const ['category']);
    if (direct != null) return direct;
    final category = ApiJson.asMap(json['category']);
    if (category == null) return '';
    return ApiJson.text(category, const ['name']) ?? '';
  }

  static String supplierNameOf(Map<String, Object?> json) {
    final supplier = ApiJson.asMap(json['supplier']);
    if (supplier == null) return '';
    return ApiJson.text(supplier, const ['companyName', 'name']) ?? '';
  }

  static String _image(Map<String, Object?> json) {
    final direct = ApiJson.text(json, const [
      'image_url',
      'imageUrl',
      'image',
      'imageAsset',
    ]);
    if (direct != null) return direct;
    final images = json['images'];
    if (images is List) {
      for (final item in images) {
        final image = ApiJson.asMap(item);
        final url = image == null ? null : ApiJson.text(image, const ['url']);
        if (url != null) return url;
      }
    }
    return AppAssets.diagnosticKit;
  }

  Map<String, Object?> toApi() => {
    'id': id,
    'name': name,
    'category': category,
    'manufacturer': manufacturer,
    'reference': reference,
    'pack_size': packSize,
    'image_url': imageAsset.startsWith('http') ? imageAsset : '',
    'brand': brand,
    'specifications': specifications,
    'barcode': barcode,
    'country_of_origin': countryOfOrigin,
    'storage_requirements': storageRequirements,
    'document_name': documentName,
  };

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'manufacturer': manufacturer,
    'reference': reference,
    'packSize': packSize,
    'imageAsset': imageAsset,
    'brand': brand,
    'specifications': specifications,
    'barcode': barcode,
    'countryOfOrigin': countryOfOrigin,
    'storageRequirements': storageRequirements,
    'documentName': documentName,
    'addedOn': addedOn,
    'supplierId': supplierId,
    'supplierUserId': supplierUserId,
    'categoryId': categoryId,
  };
}

class SupplierOfferModel {
  const SupplierOfferModel({
    required this.id,
    required this.productId,
    required this.supplierName,
    required this.price,
    required this.stock,
    required this.description,
    this.minimumOrder = 1,
    this.preparationDays = 2,
  });

  factory SupplierOfferModel.fromJson(Map<String, Object?> json) {
    return SupplierOfferModel(
      id: json['id']! as String,
      productId: json['productId']! as String,
      supplierName: json['supplierName']! as String,
      price: (json['price']! as num).toDouble(),
      stock: json['stock']! as int,
      description: json['description'] as String? ?? '',
      minimumOrder: json['minimumOrder'] as int? ?? 1,
      preparationDays: json['preparationDays'] as int? ?? 2,
    );
  }

  static SupplierOfferModel? fromProductRow(
    Map<String, Object?> row,
    ProductModel product, {
    String fallbackSupplier = '',
  }) {
    final price = ApiJson.number(row, const [
      'discountPrice',
      'sellingPrice',
      'price',
    ]);
    if (price == null) return null;
    final supplier = ProductModel.supplierNameOf(row);
    return SupplierOfferModel(
      id: product.id,
      productId: product.id,
      supplierName: supplier.isNotEmpty
          ? supplier
          : (fallbackSupplier.isEmpty ? 'Supplier' : fallbackSupplier),
      price: price,
      stock: ApiJson.integer(row, const ['stockQuantity', 'stock']) ?? 0,
      description:
          ApiJson.text(row, const ['shortDescription', 'fullDescription']) ??
          product.specifications,
      minimumOrder:
          ApiJson.integer(row, const ['minOrderQuantity', 'minimumOrder']) ?? 1,
    );
  }

  static SupplierOfferModel? tryParse(Map<String, Object?> json) {
    final id = ApiJson.text(json, const ['id', 'offer_id']);
    final productId = ApiJson.text(json, const ['product_id', 'productId']);
    final price = ApiJson.number(json, const ['price', 'unit_price']);
    if (id == null || productId == null || price == null) return null;
    return SupplierOfferModel(
      id: id,
      productId: productId,
      supplierName:
          ApiJson.text(json, const [
            'supplier_name',
            'supplierName',
            'supplier',
          ]) ??
          '',
      price: price,
      stock: ApiJson.integer(json, const ['stock', 'quantity']) ?? 0,
      description: ApiJson.text(json, const ['description']) ?? '',
      minimumOrder:
          ApiJson.integer(json, const [
            'minimum_order',
            'minimumOrder',
            'moq',
          ]) ??
          1,
      preparationDays:
          ApiJson.integer(json, const [
            'preparation_days',
            'preparationDays',
            'lead_time',
          ]) ??
          2,
    );
  }

  Map<String, Object?> toApi() => {
    'id': id,
    'product_id': productId,
    'supplier_name': supplierName,
    'price': price,
    'stock': stock,
    'description': description,
    'minimum_order': minimumOrder,
    'preparation_days': preparationDays,
  };

  final String id;
  final String productId;
  final String supplierName;
  final double price;
  final int stock;
  final String description;
  final int minimumOrder;
  final int preparationDays;

  SupplierOfferModel copyWith({
    double? price,
    int? stock,
    String? description,
    int? minimumOrder,
    int? preparationDays,
  }) {
    return SupplierOfferModel(
      id: id,
      productId: productId,
      supplierName: supplierName,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      minimumOrder: minimumOrder ?? this.minimumOrder,
      preparationDays: preparationDays ?? this.preparationDays,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'productId': productId,
    'supplierName': supplierName,
    'price': price,
    'stock': stock,
    'description': description,
    'minimumOrder': minimumOrder,
    'preparationDays': preparationDays,
  };
}
