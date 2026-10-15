import 'package:flutter/material.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class SupplierListShimmer extends StatelessWidget {
  const SupplierListShimmer({this.count = 5, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(18),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => const GlossyCard(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            ShimmerBox(height: 64, width: 64, radius: 16),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(height: 14, width: 150, radius: 6),
                  SizedBox(height: 8),
                  ShimmerBox(height: 10, width: 90, radius: 6),
                ],
              ),
            ),
            ShimmerBox(height: 16, width: 40, radius: 6),
          ],
        ),
      ),
    );
  }
}
