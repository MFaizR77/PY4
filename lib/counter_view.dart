import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});
  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LogBook: Versi SRP")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Total Hitungan:"),
            Text('${_controller.value}', style: const TextStyle(fontSize: 40)),

            const SizedBox(height: 5),

            const Text("Masukkan nilai Step:"),
            SizedBox(
              width: 200,
              child: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final step = int.tryParse(value);
                  if (step != null && step > 0) {
                    setState(() => _controller.newStep(step));
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '(batas 1-100000)',
                ),
              ),
            ),

            Text(
              'Nilai step : ${_controller.step}',
              style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 5),

            const Text("Riwayat Aktivitas:"),
            Expanded(
              child: ListView.builder(
                itemCount: _controller.recentHistory.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_controller.recentHistory[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () => setState(() => _controller.increment()),
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),

          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () => setState(() => _controller.decrement()),
            tooltip: 'Decrement',
            child: const Icon(Icons.remove),
          ),

          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () => setState(() => _controller.reset()),
            tooltip: 'Reset',
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
