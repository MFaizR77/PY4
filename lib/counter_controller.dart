class CounterController {
  int _counter = 0; // Variabel private (Enkapsulasi)
  int _step = 1; // Variabel private (Enkapsulasi)

  int get value => _counter; // Getter untuk akses data
  int get step => _step; // Getter untuk akses data

  final List<String> _history = []; // Log aktivitas

  List<String> get history => _history; // Akses log aktivitas

  void increment() {
    _counter += _step;
    _addHistory("increment", _step);
  }

  void decrement() {
    if (_counter > 0 && _counter >= _step) {
      _counter -= _step;
      _addHistory("decrement", _step);
    }
  }

  void reset() {
    _counter = 0;
    _addHistory("reset", 0);
  }

  void newStep(int step) {
    if (step > 0 && step <= 100000) {
      _step = step;
    }
    if (step > 100000) {
      _addHistory("Failed to change step", step);
    } else {
      _addHistory("Change step", step);
    }
  }

  void _addHistory(String action, int value) {
    final timestamp =
        '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    _history.add("user $action by $value at $timestamp");

    if (_history.length > 5) {
      _history.removeAt(0);
    }
  }

  List<String> get recentHistory {
    return _history.reversed.toList();
  }
}
