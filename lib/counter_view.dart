import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});
  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Reset'),
          content: const Text(
            'Apakah Anda yakin ingin mereset counter? '
            'Data tidak dapat dikembalikan.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // tutup dialog
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                setState(() => _controller.reset());
                Navigator.of(context).pop(); // tutup dialog
                _showSnackBar('Counter berhasil di-reset');
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

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

            const SizedBox(height: 10),

            const Text("Riwayat Aktivitas:"),
            Expanded(
              child: ListView.builder(
                itemCount: _controller.recentHistory.length,
                itemBuilder: (context, index) {
                  String item = _controller.recentHistory[index];

                  Color textcolor = Colors.black;
                  if (item.contains("increment")) {
                    textcolor = Colors.green;
                  } else if (item.contains("decrement")) {
                    textcolor = Colors.red;
                  } else if (item.contains("reset")) {
                    textcolor = Colors.orange;
                  }

                  return ListTile(
                    textColor: textcolor,
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
            onPressed: () => setState(() {
              _controller.increment();
            }),
            tooltip: 'Increment',
            child: const Icon(Icons.add),
            foregroundColor: Colors.green,
            backgroundColor: Colors.white,
          ),

          const SizedBox(width: 15),
          FloatingActionButton(
            onPressed: () => setState(() {
              _controller.decrement();
            }),
            tooltip: 'Decrement',
            child: const Icon(Icons.remove),
            foregroundColor: Colors.red,
            backgroundColor: Colors.white,
          ),

          const SizedBox(width: 15),
          FloatingActionButton(
            onPressed: () => _confirmReset(),
            tooltip: 'Reset',
            child: const Icon(Icons.refresh),
            foregroundColor: Colors.orange,
            backgroundColor: Colors.white,
          ),

          const SizedBox(width: 15),
          FloatingActionButton(
            onPressed: () => setState(() {
              _controller.clearHistory();
              _showSnackBar('Riwayat aktivitas telah dihapus');
            }),
            tooltip: 'Clear History',
            child: const Icon(Icons.delete),
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
          )
        ],
      ),
    );
  }
}
