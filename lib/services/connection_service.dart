import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectionService {
  static final ConnectionService _instance = ConnectionService._internal();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final ValueNotifier<bool> _isConnectedNotifier = ValueNotifier(true);
  final _onConnectionRestored = StreamController<void>.broadcast();
  
  ValueNotifier<bool> get isConnectedNotifier => _isConnectedNotifier;
  bool get isConnected => _isConnectedNotifier.value;
  Stream<void> get onConnectionRestored => _onConnectionRestored.stream;

  factory ConnectionService() => _instance;
  
  ConnectionService._internal();

  Future<void> init() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);

    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasConnected = _isConnectedNotifier.value;
    final nowConnected = results.isNotEmpty && 
        !results.contains(ConnectivityResult.none);
    
    _isConnectedNotifier.value = nowConnected;
    
    if (wasConnected != nowConnected && nowConnected) {
      if (kDebugMode) {
        print('[ConnectionService] Connection restored! Triggering sync...');
      }
      _onConnectionRestored.add(null);
    }
  }

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
    return _isConnectedNotifier.value;
  }

  void dispose() {
    _subscription?.cancel();
    _onConnectionRestored.close();
    _isConnectedNotifier.dispose();
  }
}
