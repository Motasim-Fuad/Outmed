import 'package:outmed/core/constants/app_assets.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/catalog/domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl()
    : _products = [
        const ProductModel(
          id: 'diagnostic-kit',
          name: 'Clinical Diagnostic Kit',
          category: 'Diagnostic',
          manufacturer: 'OutMed Medical',
          reference: 'OM-DK-100',
          packSize: '1 complete kit',
          imageAsset: AppAssets.diagnosticKit,
          addedOn: '10 Aug 2026',
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

  final List<ProductModel> _products;
  final List<SupplierOfferModel> _offers;

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
      throw StateError('duplicate_product');
    }
    _products.add(product);
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
    return offer;
  }

  @override
  bool deleteOffer(String id) {
    final index = _offers.indexWhere((item) => item.id == id);
    if (index < 0) return false;
    _offers.removeAt(index);
    return true;
  }
}
