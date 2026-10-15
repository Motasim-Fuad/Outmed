import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/extensions/date_label.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/dashboard_metric.dart';

class DashboardSummaryCard extends StatelessWidget {
  const DashboardSummaryCard({
    required this.orderCount,
    required this.revenue,
    required this.pendingCount,
    super.key,
  });

  final int orderCount;
  final double revenue;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F766E), Color(0xFF2BBBAD), Color(0xFF7EDCC9)],
        ),
        boxShadow: AppColors.glossyShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -12,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .14),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: 40,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'business_today'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DateTime.now().mediumLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DashboardMetric(
                        icon: Icons.shopping_bag_outlined,
                        label: 'todays_orders'.tr,
                        value: '$orderCount',
                      ),
                    ),
                    Expanded(
                      child: DashboardMetric(
                        icon: Icons.payments_outlined,
                        label: 'todays_revenue'.tr,
                        value: '${'sar'.tr} ${revenue.toStringAsFixed(0)}',
                      ),
                    ),
                    Expanded(
                      child: DashboardMetric(
                        icon: Icons.schedule_rounded,
                        label: 'pending_orders'.tr,
                        value: '$pendingCount',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
