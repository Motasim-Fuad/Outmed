import 'package:flutter/material.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class LegalShimmer extends StatelessWidget {
  const LegalShimmer({super.key});

  static const List<double?> _widths = [
    null,
    null,
    240.0,
    null,
    null,
    180.0,
    null,
    260.0,
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const ShimmerBox(height: 20, width: 200, radius: 6),
        const SizedBox(height: 16),
        for (final width in _widths) ...[
          ShimmerBox(height: 12, width: width, radius: 6),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
