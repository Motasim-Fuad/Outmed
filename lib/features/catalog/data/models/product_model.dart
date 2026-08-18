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
}
