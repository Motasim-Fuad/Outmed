import 'package:flutter/material.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class FaqShimmer extends StatelessWidget {
  const FaqShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < 4; index++)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: ShimmerBox(height: 54),
          ),
      ],
    );
  }
}
