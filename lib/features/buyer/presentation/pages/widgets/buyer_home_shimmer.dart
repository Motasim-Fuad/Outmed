import 'package:flutter/material.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class BuyerHomeShimmer extends StatelessWidget {
  const BuyerHomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const Row(
          children: [
            ShimmerBox(height: 44, width: 44, radius: 22),
            SizedBox(width: 10),
            Expanded(child: ShimmerBox(height: 18, radius: 6)),
            SizedBox(width: 60),
            ShimmerBox(height: 28, width: 28, radius: 14),
          ],
        ),
        const SizedBox(height: 16),
        const ShimmerBox(height: 48, radius: 28),
        const SizedBox(height: 16),
        const ShimmerBox(height: 168, radius: 22),
        const SizedBox(height: 22),
        const ShimmerBox(height: 18, width: 160, radius: 6),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var index = 0; index < 4; index++) ...[
              const ShimmerBox(height: 52, width: 52, radius: 26),
              const SizedBox(width: 22),
            ],
          ],
        ),
        const SizedBox(height: 22),
        const ShimmerBox(height: 18, width: 180, radius: 6),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(child: ShimmerBox(height: 240, radius: 16)),
            SizedBox(width: 12),
            Expanded(child: ShimmerBox(height: 240, radius: 16)),
          ],
        ),
      ],
    );
  }
}
