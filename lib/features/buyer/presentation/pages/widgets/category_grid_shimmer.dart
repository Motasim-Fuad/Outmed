import 'package:flutter/material.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class CategoryGridShimmer extends StatelessWidget {
  const CategoryGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: .86,
      ),
      itemCount: 6,
      itemBuilder: (context, index) =>
          const ShimmerBox(height: 110, radius: 16),
    );
  }
}
