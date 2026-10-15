import 'package:flutter/material.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class SupplierProfileShimmer extends StatelessWidget {
  const SupplierProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        GlossyCard(
          padding: EdgeInsets.all(18),
          child: Column(
            children: [
              ShimmerBox(height: 72, width: 72, radius: 18),
              SizedBox(height: 12),
              ShimmerBox(height: 18, width: 180, radius: 6),
              SizedBox(height: 8),
              ShimmerBox(height: 12, width: 140, radius: 6),
            ],
          ),
        ),
        SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: ShimmerBox(height: 64, radius: 16)),
            SizedBox(width: 8),
            Expanded(child: ShimmerBox(height: 64, radius: 16)),
            SizedBox(width: 8),
            Expanded(child: ShimmerBox(height: 64, radius: 16)),
          ],
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ShimmerBox(height: 32, width: 120, radius: 16),
            ShimmerBox(height: 32, width: 110, radius: 16),
            ShimmerBox(height: 32, width: 100, radius: 16),
          ],
        ),
        SizedBox(height: 18),
        ShimmerBox(height: 18, width: 140, radius: 6),
        SizedBox(height: 10),
        ShimmerBox(height: 12, radius: 6),
        SizedBox(height: 6),
        ShimmerBox(height: 12, radius: 6),
        SizedBox(height: 6),
        ShimmerBox(height: 12, width: 200, radius: 6),
        SizedBox(height: 24),
        ShimmerBox(height: 52, radius: 26),
      ],
    );
  }
}
