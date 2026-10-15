import 'package:flutter/material.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class ConversationListShimmer extends StatelessWidget {
  const ConversationListShimmer({this.count = 5, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < count; index++)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: GlossyCard(
              padding: EdgeInsets.all(13),
              child: Row(
                children: [
                  ShimmerBox(height: 48, width: 48, radius: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(height: 14, width: 140, radius: 6),
                        SizedBox(height: 8),
                        ShimmerBox(height: 10, radius: 6),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  ShimmerBox(height: 10, width: 32, radius: 6),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
