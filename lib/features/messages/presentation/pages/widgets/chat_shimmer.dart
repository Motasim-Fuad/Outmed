import 'package:flutter/material.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class ChatShimmer extends StatelessWidget {
  const ChatShimmer({super.key});

  static const _widths = [220.0, 160.0, 240.0, 120.0, 200.0, 180.0];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _widths.length,
      itemBuilder: (context, index) => Align(
        alignment: index.isOdd
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ShimmerBox(height: 42, width: _widths[index], radius: 16),
        ),
      ),
    );
  }
}
