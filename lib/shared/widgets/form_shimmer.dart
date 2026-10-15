import 'package:flutter/material.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class FormShimmer extends StatelessWidget {
  const FormShimmer({this.fields = 7, super.key});

  final int fields;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var index = 0; index < fields; index++) ...[
          const ShimmerBox(height: 52),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 10),
        const ShimmerBox(height: 52, radius: 14),
      ],
    );
  }
}
