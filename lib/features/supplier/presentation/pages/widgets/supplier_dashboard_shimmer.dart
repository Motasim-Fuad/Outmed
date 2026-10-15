import 'package:flutter/material.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class SupplierDashboardShimmer extends StatelessWidget {
  const SupplierDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const Row(
          children: [
            ShimmerBox(height: 44, width: 44, radius: 22),
            SizedBox(width: 10),
            Expanded(child: ShimmerBox(height: 18, radius: 6)),
            SizedBox(width: 80),
          ],
        ),
        const SizedBox(height: 16),
        const ShimmerBox(height: 190, radius: 22),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(child: ShimmerBox(height: 86, radius: 16)),
            SizedBox(width: 8),
            Expanded(child: ShimmerBox(height: 86, radius: 16)),
            SizedBox(width: 8),
            Expanded(child: ShimmerBox(height: 86, radius: 16)),
          ],
        ),
        const SizedBox(height: 22),
        const ShimmerBox(height: 18, width: 150, radius: 6),
        const SizedBox(height: 12),
        for (var index = 0; index < 3; index++) ...[
          const ShimmerBox(height: 92, radius: 16),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
