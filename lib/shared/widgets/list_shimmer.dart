import 'package:flutter/material.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class ListShimmer extends StatelessWidget {
  const ListShimmer({this.count = 4, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => const ShimmerBox(height: 92, radius: 16),
    );
  }
}
