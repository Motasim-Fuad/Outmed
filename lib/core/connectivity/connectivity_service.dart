import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  ConnectivityService._();

  static final instance = ConnectivityService._();
  final online = ValueNotifier<bool>(true);
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void start() {
    _subscription ??= Connectivity().onConnectivityChanged.listen((results) {
      online.value = results.any((result) => result != ConnectivityResult.none);
    });
  }

  void dispose() {
    // cancel() returns a Future; this service does not await teardown.
    // ignore: discarded_futures
    _subscription?.cancel();
    _subscription = null;
  }
}
