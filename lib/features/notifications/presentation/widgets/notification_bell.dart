import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:outmed/features/notifications/presentation/bloc/notification_state.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({this.color, super.key});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<NotificationBloc, NotificationState, int>(
      selector: (state) => state.unread,
      builder: (context, unread) => IconButton(
        onPressed: () => AppNav.push(AppRoutes.notifications),
        icon: Badge(
          isLabelVisible: unread > 0,
          backgroundColor: AppColors.danger,
          label: Text(unread > 9 ? '9+' : '$unread'),
          child: Icon(Icons.notifications_none_rounded, color: color),
        ),
      ),
    );
  }
}
