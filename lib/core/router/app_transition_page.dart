import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:outmed/core/constants/app_durations.dart';

class AppTransitionPage<T> extends CustomTransitionPage<T> {
  AppTransitionPage({required super.child, required super.name})
    : super(
        key: ValueKey(name),
        transitionDuration: AppDurations.page,
        reverseTransitionDuration: AppDurations.fade,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          if (MediaQuery.disableAnimationsOf(context)) return child;
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      );
}
