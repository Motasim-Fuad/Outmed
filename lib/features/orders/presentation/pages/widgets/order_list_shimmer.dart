import 'package:flutter/material.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class OrderListShimmer extends StatelessWidget {
  const OrderListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(18),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(height: 16, width: 120, radius: 6),
              Spacer(),
              ShimmerBox(height: 22, width: 80, radius: 11),
            ],
          ),
          SizedBox(height: 14),
          ShimmerBox(height: 16, width: 200, radius: 6),
          SizedBox(height: 8),
          ShimmerBox(height: 12, width: 150, radius: 6),
          SizedBox(height: 14),
          ShimmerBox(height: 28, radius: 8),
        ],
      ),
    );
  }
}
