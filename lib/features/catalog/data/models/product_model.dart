import 'dart:typed_data';

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

  String get searchableText =>
      '$name $category $brand $manufacturer $reference $barcode'.toLowerCase();

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
