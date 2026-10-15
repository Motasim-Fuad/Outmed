import 'package:flutter/material.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class NotificationsShimmer extends StatelessWidget {
  const NotificationsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(18),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, _) => const GlossyCard(
        padding: EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(height: 40, width: 40, radius: 20),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(height: 14, width: 160, radius: 6),
                  SizedBox(height: 8),
                  ShimmerBox(height: 10, radius: 6),
                  SizedBox(height: 6),
                  ShimmerBox(height: 10, width: 120, radius: 6),
                ],
              ),
            ),
            SizedBox(width: 8),
            ShimmerBox(height: 10, width: 30, radius: 6),
          ],
        ),
      ),
    );
  }
}
