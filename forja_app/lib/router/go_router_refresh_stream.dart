import 'dart:async';
import 'package:flutter/foundation.dart';

/// Faz o GoRouter "ouvir" um Stream (ex.: mudanças de login) e re-avaliar o redirect.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
