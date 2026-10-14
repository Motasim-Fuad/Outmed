import 'dart:async';

import 'package:go_router/go_router.dart';

class AppNav {
  static late GoRouter router;

  static void push(String location, {Object? extra}) {
    unawaited(router.push(location, extra: extra));
  }

  static void go(String location, {Object? extra}) {
    router.go(location, extra: extra);
  }

  static void pop<T extends Object?>([T? result]) {
    if (router.canPop()) {
      router.pop(result);
    }
  }
}
