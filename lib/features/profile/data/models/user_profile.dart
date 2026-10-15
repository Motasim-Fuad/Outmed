import 'package:equatable/equatable.dart';
import 'package:outmed/core/network/api_json.dart';

class UserProfile extends Equatable {
  const UserProfile({
    this.userId = '',
    this.email = '',
    this.fullName = '',
    this.phone = '',
    this.role = '',
    this.organization = '',
    this.companyType = '',
    this.logoUrl = '',
    this.bankName = '',
    this.bankAccountHolderName = '',
    this.iban = '',
    this.country = '',
    this.city = '',
    this.fullAddress = '',
    this.postalCode = '',
    this.pickupAddress = '',
    this.website = '',
    this.yearsEstablished = '',
    this.numberOfEmployees = '',
    this.onboardingComplete = true,
  });

  factory UserProfile.parse(Object? body) {
    final root = ApiJson.asMap(ApiJson.unwrap(body)) ?? const {};
    final user = ApiJson.asMap(root['user']) ?? root;
    final org =
        ApiJson.asMap(root['supplierProfile']) ??
        ApiJson.asMap(root['buyerProfile']) ??
        ApiJson.asMap(user['supplierProfile']) ??
        ApiJson.asMap(user['buyerProfile']) ??
        ApiJson.asMap(root['profile']) ??
        root;
    String pick(List<String> keys) =>
        ApiJson.text(org, keys) ?? ApiJson.text(root, keys) ?? '';
    final onboarding = root['onboardingStatus'] ?? root['onboarding'];
    final onboardingMap = ApiJson.asMap(onboarding);
    final completed =
        root['isOnboarded'] ??
        root['onboardingCompleted'] ??
        onboardingMap?['completed'] ??
        onboardingMap?['isComplete'] ??
        (onboarding is String ? onboarding == 'COMPLETED' : null);
    return UserProfile(
      userId:
          ApiJson.text(user, const ['id', 'userId']) ??
          ApiJson.text(root, const ['userId']) ??
          '',
      email: ApiJson.text(user, const ['email']) ?? '',
      fullName: ApiJson.text(user, const ['fullName', 'name']) ?? '',
      phone: ApiJson.text(user, const ['phone']) ?? pick(const ['phone']),
      role: ApiJson.text(user, const ['role']) ?? pick(const ['role']),
      organization: pick(const ['organizationName', 'companyName']),
      companyType: pick(const ['companyType']),
      logoUrl: pick(const ['logoUrl']),
      bankName: pick(const ['bankName']),
      bankAccountHolderName: pick(const ['bankAccountHolderName']),
      iban: pick(const ['iban']),
      country: pick(const ['country', 'businessCountry']),
      city: pick(const ['city', 'businessCity']),
      fullAddress: pick(const [
        'fullAddress',
        'addressLine1',
        'businessAddressLine1',
      ]),
      postalCode: pick(const ['postalCode', 'businessPostalCode']),
      pickupAddress: pick(const ['pickupAddress', 'pickupAddressLine1']),
      website: pick(const ['website', 'companyWebsite']),
      yearsEstablished: pick(const ['yearsEstablished']),
      numberOfEmployees: pick(const ['numberOfEmployees']),
      onboardingComplete: completed != false,
    );
  }

  static const empty = UserProfile();

  final String userId;
  final String email;
  final String fullName;
  final String phone;
  final String role;
  final String organization;
  final String companyType;
  final String logoUrl;
  final String bankName;
  final String bankAccountHolderName;
  final String iban;
  final String country;
  final String city;
  final String fullAddress;
  final String postalCode;
  final String pickupAddress;
  final String website;
  final String yearsEstablished;
  final String numberOfEmployees;
  final bool onboardingComplete;

  bool get isEmpty => userId.isEmpty && email.isEmpty;

  String get displayName {
    if (fullName.isNotEmpty) return fullName.split(' ').first;
    if (organization.isNotEmpty) return organization;
    return email.split('@').first;
  }

  String get addressLine => [
    fullAddress,
    city,
    postalCode,
    country,
  ].where((part) => part.isNotEmpty).join(', ');

  @override
  List<Object?> get props => [
    userId,
    email,
    fullName,
    phone,
    role,
    organization,
    companyType,
    logoUrl,
    bankName,
    bankAccountHolderName,
    iban,
    country,
    city,
    fullAddress,
    postalCode,
    pickupAddress,
    website,
    yearsEstablished,
    numberOfEmployees,
    onboardingComplete,
  ];
}
