import 'package:flutter/material.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class BuyerHomeShimmer extends StatelessWidget {
  const BuyerHomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(18, 16, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(height: 44, width: 220, radius: 22),
          SizedBox(height: 16),
          ShimmerBox(height: 48, radius: 28),
          SizedBox(height: 16),
          ShimmerBox(height: 168, radius: 24),
          SizedBox(height: 22),
          ShimmerBox(height: 18, width: 160),
          SizedBox(height: 12),
          Row(
            children: [
              ShimmerBox(height: 72, width: 72, radius: 36),
              SizedBox(width: 12),
              ShimmerBox(height: 72, width: 72, radius: 36),
              SizedBox(width: 12),
              ShimmerBox(height: 72, width: 72, radius: 36),
            ],
          ),
        ],
      ),
    );
  }
}
