import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';

sealed class SupplierEvent extends Equatable {
  const SupplierEvent();

  @override
  List<Object?> get props => [];
}

class SupplierStarted extends SupplierEvent {
  const SupplierStarted();
}

class SupplierShellSelected extends SupplierEvent {
  const SupplierShellSelected(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

class SupplierSearchChanged extends SupplierEvent {
  const SupplierSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class SupplierProductSelected extends SupplierEvent {
  const SupplierProductSelected(this.product);

  final ProductModel product;

  @override
  List<Object?> get props => [product.id];
}

class SupplierSelectionCleared extends SupplierEvent {
  const SupplierSelectionCleared();
}

class SupplierProductCreateRequested extends SupplierEvent {
  const SupplierProductCreateRequested({
    required this.name,
    required this.category,
    required this.manufacturer,
    required this.reference,
    required this.packSize,
    required this.brand,
    required this.specifications,
    required this.barcode,
    required this.countryOfOrigin,
    required this.storageRequirements,
    required this.documentName,
    required this.imageBytes,
  });

  final String name;
  final String category;
  final String manufacturer;
  final String reference;
  final String packSize;
  final String brand;
  final String specifications;
  final String barcode;
  final String countryOfOrigin;
  final String storageRequirements;
  final String documentName;
  final Uint8List imageBytes;

  @override
  List<Object?> get props => [name, reference];
}

class SupplierOfferSaveRequested extends SupplierEvent {
  const SupplierOfferSaveRequested({
    required this.product,
    required this.price,
    required this.stock,
    required this.description,
    required this.minimumOrder,
    required this.preparationDays,
    this.existing,
  });

  final ProductModel product;
  final double price;
  final int stock;
  final String description;
  final int minimumOrder;
  final int preparationDays;
  final SupplierOfferModel? existing;

  @override
  List<Object?> get props => [product.id, price, stock, existing?.id];
}

class SupplierOfferDeleteRequested extends SupplierEvent {
  const SupplierOfferDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
