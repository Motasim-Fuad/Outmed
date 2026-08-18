import 'package:outmed/core/constants/app_assets.dart';

class MarketplaceSupplier {
  const MarketplaceSupplier({
    required this.name,
    required this.logo,
    required this.rating,
    required this.reviews,
    required this.years,
    required this.productsCount,
    required this.aboutKey,
  });

  final String name;
  final String logo;
  final String rating;
  final String reviews;
  final String years;
  final String productsCount;
  final String aboutKey;

  static const healthCare = MarketplaceSupplier(
    name: 'HealthCare Supplies',
    logo: AppAssets.healthCareLogo,
    rating: '4.5',
    reviews: '8K',
    years: '2+',
    productsCount: '1K+',
    aboutKey: 'about_healthcare',
  );

  static const marshMedical = MarketplaceSupplier(
    name: 'Marsh Medical',
    logo: AppAssets.marshMedicalLogo,
    rating: '4.8',
    reviews: '3K',
    years: '5+',
    productsCount: '640',
    aboutKey: 'about_marsh',
  );

  static const all = [healthCare, marshMedical];

  static MarketplaceSupplier byName(String name) {
    return all.firstWhere(
      (supplier) => supplier.name == name,
      orElse: () => healthCare,
    );
  }
}
