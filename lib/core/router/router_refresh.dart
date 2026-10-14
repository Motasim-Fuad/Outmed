import 'dart:async';

import 'package:flutter/widgets.dart';

class RouterRefresh extends ChangeNotifier {
  RouterRefresh(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
