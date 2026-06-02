import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectionStateStatus { connected, reconnecting, disconnected }

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, ConnectionStateStatus>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<ConnectionStateStatus> {
  final Connectivity _connectivity = Connectivity();

  ConnectivityNotifier() : super(ConnectionStateStatus.connected) {
    _init();
  }

  void _init() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.none)) {
        state = ConnectionStateStatus.disconnected;
      } else {
        if (state == ConnectionStateStatus.disconnected) {
          state = ConnectionStateStatus.reconnecting;
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) state = ConnectionStateStatus.connected;
          });
        } else {
          state = ConnectionStateStatus.connected;
        }
      }
    });
  }
}
