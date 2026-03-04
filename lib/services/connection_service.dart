import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectionService {
  static final ConnectionService _instance = ConnectionService._internal();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final ValueNotifier<bool> _isConnectedNotifier = ValueNotifier(true);
  
  ValueNotifier<bool> get isConnectedNotifier => _isConnectedNotifier;
  bool get isConnected => _isConnectedNotifier.value;

  factory ConnectionService() => _instance;
  
  ConnectionService._internal();

  Future<void> init() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);

    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasConnected = _isConnectedNotifier.value;
    _isConnectedNotifier.value = results.isNotEmpty && 
        !results.contains(ConnectivityResult.none);
    
    if (wasConnected != _isConnectedNotifier.value) {
      if (kDebugMode) {
        print('[ConnectionService] Connection changed: ${_isConnectedNotifier.value}');
      }
    }
  }

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
    return _isConnectedNotifier.value;
  }

  void dispose() {
    _subscription?.cancel();
    _isConnectedNotifier.dispose();
  }
}
