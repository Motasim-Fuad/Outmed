import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/extensions/date_label.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/features/supplier/data/models/stock_log.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';

class StockLogTile extends StatelessWidget {
  const StockLogTile({required this.log, super.key});

  final StockLog log;

  @override
  Widget build(BuildContext context) {
    final increase = log.adjustment >= 0;
    final color = increase ? AppColors.success : AppColors.danger;
    final reasonKey = 'stock_reason_${log.reason.toLowerCase()}';
    final reason = reasonKey.tr == reasonKey ? log.reason : reasonKey.tr;
    final previous = log.previousStock;
    final next = log.newStock;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlossyCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: .12),
              child: Icon(
                increase
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reason,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  if (previous != null && next != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$previous → $next ${'units'.tr}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (log.notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(log.notes, style: const TextStyle(fontSize: 12)),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    log.createdAt.dateTimeLabel,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${increase ? '+' : ''}${log.adjustment}',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
