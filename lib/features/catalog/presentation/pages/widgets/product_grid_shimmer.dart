import 'package:flutter/material.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class ProductGridShimmer extends StatelessWidget {
  const ProductGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: .70,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, _) => const ShimmerBox(height: double.infinity, radius: 16),
          childCount: 6,
        ),
      ),
    );
  }
}
