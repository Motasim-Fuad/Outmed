import 'package:flutter/material.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class InventoryShimmer extends StatelessWidget {
  const InventoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const ShimmerBox(height: 24, width: 140, radius: 6),
        const SizedBox(height: 8),
        const ShimmerBox(height: 12, width: 220, radius: 6),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(child: ShimmerBox(height: 84, radius: 16)),
            SizedBox(width: 8),
            Expanded(child: ShimmerBox(height: 84, radius: 16)),
            SizedBox(width: 8),
            Expanded(child: ShimmerBox(height: 84, radius: 16)),
          ],
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            ShimmerBox(height: 32, width: 110, radius: 16),
            SizedBox(width: 8),
            ShimmerBox(height: 32, width: 90, radius: 16),
            SizedBox(width: 8),
            ShimmerBox(height: 32, width: 100, radius: 16),
          ],
        ),
        const SizedBox(height: 14),
        for (var index = 0; index < 5; index++) ...[
          const ShimmerBox(height: 76, radius: 16),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
