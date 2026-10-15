import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/di/injection.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/network/remote_cache.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/profile/presentation/bloc/login_activity_bloc.dart';
import 'package:outmed/features/profile/presentation/bloc/login_activity_event.dart';
import 'package:outmed/features/profile/presentation/bloc/login_activity_state.dart';
import 'package:outmed/features/profile/presentation/pages/widgets/login_activity_tile.dart';
import 'package:outmed/shared/widgets/list_shimmer.dart';

class LoginActivityPage extends StatelessWidget {
  const LoginActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          LoginActivityBloc(getIt<RemoteCache>())
            ..add(const LoginActivitiesRequested()),
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(title: Text('login_activity'.tr)),
        body:
            BlocSelector<
              LoginActivityBloc,
              LoginActivityState,
              LoginActivityState
            >(
              selector: (state) => state,
              builder: (context, state) {
                if (state.loading) return const ListShimmer(count: 6);
                return RefreshIndicator(
                  onRefresh: () async {
                    final bloc = context.read<LoginActivityBloc>()
                      ..add(const LoginActivitiesRequested());
                    await bloc.stream.firstWhere(
                      (item) => item.status != LoadStatus.loading,
                    );
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                    children: [
                      Text(
                        'login_activity_hint'.tr,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 14),
                      if (state.activities.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(
                            state.errorMessage.isEmpty
                                ? 'no_login_activity'.tr
                                : state.errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.muted),
                          ),
                        )
                      else
                        for (final activity in state.activities)
                          LoginActivityTile(activity: activity),
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }
}
