import 'package:equatable/equatable.dart';
import 'package:outmed/core/constants/app_assets.dart';
import 'package:outmed/core/network/api_json.dart';

class MarketplaceSupplier extends Equatable {
  const MarketplaceSupplier({
    required this.name,
    required this.logo,
    required this.rating,
    required this.reviews,
    required this.years,
    required this.productsCount,
    this.aboutKey = '',
    this.about = '',
    this.id = '',
    this.userId = '',
    this.country = '',
    this.companyType = '',
    this.verified = true,
  });

  final String id;
  final String userId;
  final String name;
  final String logo;
  final String rating;
  final String reviews;
  final String years;
  final String productsCount;
  final String aboutKey;
  final String about;
  final String country;
  final String companyType;
  final bool verified;

  bool get isRemote => id.isNotEmpty;

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

  static const List<MarketplaceSupplier> all = [healthCare, marshMedical];

  static MarketplaceSupplier byName(String name) {
    return all.firstWhere(
      (supplier) => supplier.name == name,
      orElse: () => healthCare,
    );
  }

  static MarketplaceSupplier? tryParse(Map<String, Object?> json) {
    final id = ApiJson.text(json, const ['id', 'supplierId']);
    final name = ApiJson.text(json, const ['companyName', 'name']);
    if (id == null || name == null) return null;
    final user = ApiJson.asMap(json['user']);
    final established = ApiJson.integer(json, const ['yearsEstablished']);
    final rating = ApiJson.number(json, const ['rating', 'averageRating']);
    final reviews = ApiJson.integer(json, const [
      'reviewsCount',
      'totalReviews',
      'reviewCount',
    ]);
    final products = ApiJson.integer(json, const [
      'productsCount',
      'productCount',
      'totalProducts',
    ]);
    final count = ApiJson.asMap(json['_count']);
    final years = established == null
        ? ''
        : '${(DateTime.now().year - established).clamp(0, 300)}+';
    return MarketplaceSupplier(
      id: id,
      userId:
          ApiJson.text(json, const ['userId']) ??
          (user == null ? null : ApiJson.text(user, const ['id'])) ??
          '',
      name: name,
      logo: ApiJson.text(json, const ['logoUrl', 'logo']) ?? '',
      rating: rating == null ? '-' : rating.toStringAsFixed(1),
      reviews: reviews?.toString() ?? '0',
      years: years.isEmpty ? '-' : years,
      productsCount:
          (products ??
                  (count == null
                      ? null
                      : ApiJson.integer(count, const ['products'])) ??
                  0)
              .toString(),
      about: ApiJson.text(json, const ['description', 'about']) ?? '',
      country: ApiJson.text(json, const ['country', 'businessCountry']) ?? '',
      companyType: ApiJson.text(json, const ['companyType']) ?? '',
      verified: json['isVerified'] != false,
    );
  }

  @override
  List<Object?> get props => [id, name, logo, rating, years, productsCount];
}
