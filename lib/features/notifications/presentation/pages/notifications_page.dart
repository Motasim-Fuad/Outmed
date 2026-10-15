import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/notifications/data/models/app_notification.dart';
import 'package:outmed/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:outmed/features/notifications/presentation/bloc/notification_event.dart';
import 'package:outmed/features/notifications/presentation/bloc/notification_state.dart';
import 'package:outmed/features/notifications/presentation/pages/widgets/notification_tile.dart';
import 'package:outmed/features/notifications/presentation/pages/widgets/notifications_shimmer.dart';
import 'package:outmed/shared/widgets/inline_error_text.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const NotificationsStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text('notifications'.tr),
        actions: [
          BlocSelector<NotificationBloc, NotificationState, int>(
            selector: (state) => state.unread,
            builder: (context, unread) => unread == 0
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () => context.read<NotificationBloc>().add(
                      const NotificationsAllRead(),
                    ),
                    child: Text('mark_all_read'.tr),
                  ),
          ),
        ],
      ),
      body:
          BlocSelector<
            NotificationBloc,
            NotificationState,
            (LoadStatus, List<AppNotification>, String)
          >(
            selector: (state) =>
                (state.status, state.items, state.errorMessage),
            builder: (context, data) {
              final (status, items, error) = data;
              if (status == LoadStatus.loading && items.isEmpty) {
                return const NotificationsShimmer();
              }
              return RefreshIndicator(
                onRefresh: () async => context.read<NotificationBloc>().add(
                  const NotificationsStarted(),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    if (status == LoadStatus.failure)
                      InlineErrorText(message: error),
                    if (items.isEmpty && status != LoadStatus.failure)
                      Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.notifications_off_outlined,
                              size: 48,
                              color: AppColors.muted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'no_notifications'.tr,
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    for (final item in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: NotificationTile(notification: item),
                      ),
                  ],
                ),
              );
            },
          ),
    );
  }
}
