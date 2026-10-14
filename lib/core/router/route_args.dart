import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class RouteArgs {
  static T of<T>(BuildContext context) => GoRouterState.of(context).extra as T;

  static T? maybe<T>(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    return extra is T ? extra : null;
  }
}
