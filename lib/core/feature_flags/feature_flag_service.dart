import 'package:outmed/core/feature_flags/feature_key.dart';

class FeatureFlagService {
  final _values = <FeatureKey, bool>{
    FeatureKey.buyerCheckout: true,
    FeatureKey.supplierOffers: true,
    FeatureKey.messages: true,
    FeatureKey.stripePayments: true,
    FeatureKey.maintenance: false,
    FeatureKey.forceUpdate: false,
  };

  bool isEnabled(FeatureKey key) => _values[key] ?? false;

  void apply(Map<String, bool> remote) {
    for (final key in FeatureKey.values) {
      final value = remote[key.name];
      if (value != null) _values[key] = value;
    }
  }
}
