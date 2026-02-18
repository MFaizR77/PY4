import 'package:shared_preferences/shared_preferences.dart';
import "dart:convert";

class CounterController {
  int _counter = 0; // Variabel private (Enkapsulasi)
  int _step = 1; // Variabel private (Enkapsulasi)

  int get value => _counter; // Getter untuk akses data
  int get step => _step; // Getter untuk akses data

  String _CurrentUserName = ""; // Variabel untuk menyimpan username

  final List<String> _history = []; // Log aktivitas

  List<String> get history => _history; // Akses log aktivitas

  void setUsername(String username) {
    _CurrentUserName = username;
  }

  Future<void> saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_counter_$_CurrentUserName', _counter);
    // Simpan history sebagai JSON string
    await prefs.setString('history_$_CurrentUserName', jsonEncode(_history));
  }

  Future<void> loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('last_counter_$_CurrentUserName') ?? 0;
    final historyString = prefs.getString('history_$_CurrentUserName');
    if (historyString != null) {
      final List<dynamic> decoded = jsonDecode(historyString);
      _history
        ..clear()
        ..addAll(decoded.map((e) => e.toString()));
    }
  }

  void increment(String username) {
    _counter += _step;
    _addHistory("$username increment step", _step);
    saveCounter();
  }

  void decrement(String username) {
    if (_counter > 0 && _counter >= _step) {
      _counter -= _step;
      _addHistory("$username decrement step", _step);
      saveCounter();
    }
  }

  void reset(String username) {
    _counter = 0;
    _addHistory("$username reset step", 0);
    saveCounter();
  }

  void newStep(int step, String username) {
    if (step > 0 && step <= 100000) {
      _step = step;
    }
    if (step > 100000) {
      _step = 100000;
      _addHistory("$username Failed to change step", step);
    } else {
      _addHistory("$username Change step", step);
    }
    saveCounter();
  }

  void _addHistory(String action, int value) {
    final timestamp =
        '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    _history.add("$action by $value at $timestamp");

    if (_history.length > 5) {
      _history.removeAt(0);
    }
  }

  String currentTime(String username) {
    String current = "pagi";
    final currentTime =
        '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    final currentHour = DateTime.now().hour;
    if (currentHour >= 0 && currentHour < 12) {
      current = "Pagi";
    } else if (currentHour >= 12 && currentHour < 15) {
      current = "Siang";
    } else if (currentHour >= 15 && currentHour < 18) {
      current = "Sore";
    } else {
      current = "Malam";
    }

    return "Selamat ${current.substring(0,1).toUpperCase()}${current.substring(1).toLowerCase()}, $username, anda login pada $currentTime";
  }

  List<String> get recentHistory {
    return _history.reversed.toList();
  }

  void clearHistory() {
    _history.clear();
    saveCounter();
  }
}
