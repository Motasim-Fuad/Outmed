import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/di/injection.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/network/remote_cache.dart';
import 'package:outmed/features/supplier/presentation/bloc/stock_log_bloc.dart';
import 'package:outmed/features/supplier/presentation/bloc/stock_log_event.dart';
import 'package:outmed/features/supplier/presentation/bloc/stock_log_state.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/stock_log_tile.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class StockHistorySection extends StatelessWidget {
  const StockHistorySection({required this.productId, super.key});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          StockLogBloc(getIt<RemoteCache>())
            ..add(StockLogsRequested(productId)),
      child: BlocSelector<StockLogBloc, StockLogState, StockLogState>(
        selector: (state) => state,
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'stock_history'.tr,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              if (state.loading)
                for (var index = 0; index < 3; index++)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: ShimmerBox(height: 74, radius: 16),
                  )
              else if (state.logs.isEmpty)
                Text(
                  state.errorMessage.isEmpty
                      ? 'no_stock_history'.tr
                      : state.errorMessage,
                  style: const TextStyle(color: AppColors.muted),
                )
              else
                for (final log in state.logs) StockLogTile(log: log),
            ],
          );
        },
      ),
    );
  }
}
