// import 'package:flutter/material.dart';
// import 'package:logbook_app_001/features/logbook/counter_controller.dart';
// import 'package:logbook_app_001/features/auth/login_view.dart';
// import 'package:logbook_app_001/features/onboarding/onboarding_view.dart';
// import 'package:logbook_app_001/features/logbook/log_controller.dart';
// import '../logbook/models/log_model.dart';

// class CounterView extends StatefulWidget {
//   final String username;

//   const CounterView({super.key, required this.username});

//   @override
//   State<CounterView> createState() => _CounterViewState();
// }

// class _CounterViewState extends State<CounterView> {
//   final CounterController _controller = CounterController();
//   final LogController _logController = LogController();
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _contentController = TextEditingController();

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _controller.setUsername(widget.username);
//     _loadSavedCounter();
//   }

//   Future<void> _loadSavedCounter() async {
//     await _controller.loadCounter();
//     setState(() {});
//   }

//   // void _confirmReset() {
//   //   showDialog(
//   //     context: context,
//   //     builder: (context) {
//   //       return AlertDialog(
//   //         title: const Text('Konfirmasi Reset'),
//   //         content: const Text(
//   //           'Apakah Anda yakin ingin mereset counter? '
//   //           'Data tidak dapat dikembalikan.',
//   //         ),
//   //         actions: [
//   //           TextButton(
//   //             onPressed: () {
//   //               Navigator.of(context).pop(); // tutup dialog
//   //             },
//   //             child: const Text('Batal'),
//   //           ),
//   //           TextButton(
//   //             onPressed: () {
//   //               setState(() => _controller.reset(widget.username));
//   //               Navigator.of(context).pop(); // tutup dialog
//   //               _showSnackBar('Counter berhasil di-reset');
//   //             },
//   //             child: const Text('Ya'),
//   //           ),
//   //         ],
//   //       );
//   //     },
//   //   );
//   // }

//   void _showEditLogDialog(int index, LogModel log) {
//     _titleController.text = log.title;
//     _contentController.text = log.description;
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Edit Catatan"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(controller: _titleController),
//             TextField(controller: _contentController),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Batal"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               _logController.updateLog(
//                 index,
//                 _titleController.text,
//                 _contentController.text,
//               );
//               _titleController.clear();
//               _contentController.clear();
//               Navigator.pop(context);
//             },
//             child: const Text("Update"),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAddLogDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Tambah Catatan Baru"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min, // Agar dialog tidak memenuhi layar
//           children: [
//             TextField(
//               controller: _titleController,
//               decoration: const InputDecoration(hintText: "Judul Catatan"),
//             ),
//             TextField(
//               controller: _contentController,
//               decoration: const InputDecoration(hintText: "Isi Deskripsi"),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context), // Tutup tanpa simpan
//             child: const Text("Batal"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Jalankan fungsi tambah di Controller
//               _logController.addLog(
//                 _titleController.text,
//                 _contentController.text,
//               );

//               // Trigger UI Refresh
//               setState(() {});

//               // Bersihkan input dan tutup dialog
//               _titleController.clear();
//               _contentController.clear();
//               Navigator.pop(context);
//             },
//             child: const Text("Simpan"),
//           ),
//         ],
//       ),
//     );
//   }

//   void _logout() {
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => const OnboardingView()),
//       (route) => false,
//     );
//   }

//   void _confirmLogout() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Konfirmasi Logout'),
//           content: Text('Apakah Anda yakin ingin logout, ${widget.username}?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Batal'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _logout();
//               },
//               child: const Text('Logout', style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("LogBook - ${widget.username}"),
//         actions: [
//           IconButton(
//             onPressed: _confirmLogout,
//             icon: const Icon(Icons.logout),
//             tooltip: 'Logout',
//           ),
//         ],
//       ),

//       body: ValueListenableBuilder<List<LogModel>>(
//         valueListenable: _logController.logsNotifier,
//         builder: (context, currentLogs, child) {
//           if (currentLogs.isEmpty)
//             return const Center(child: Text("Belum ada catatan."));
//           return ListView.builder(
//             itemCount: currentLogs.length,
//             itemBuilder: (context, index) {
//               final log = currentLogs[index];
//               return Card(
//                 child: ListTile(
//                   leading: const Icon(Icons.note),
//                   title: Text(log.title),
//                   subtitle: Text(log.description),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.edit, color: Colors.blue),
//                         onPressed: () => _showEditLogDialog(index, log),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () => _logController.removeLog(index),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),

//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddLogDialog, // Panggil fungsi dialog yang baru dibuat
//         child: const Icon(Icons.add),
//       ),

//       // body: Center(
//       //   child: Column(
//       //     mainAxisAlignment: MainAxisAlignment.center,
//       //     children: [
//       //       // Welcome Message
//       //       // Container(
//       //       //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       //       //   decoration: BoxDecoration(
//       //       //     color: Theme.of(context).colorScheme.primaryContainer,
//       //       //     borderRadius: BorderRadius.circular(20),
//       //       //   ),
//       //       //   child: Text(
//       //       //     _controller.currentTime(widget.username),
//       //       //     style: TextStyle(
//       //       //       fontSize: 16,
//       //       //       fontWeight: FontWeight.w500,
//       //       //       color: Theme.of(context).colorScheme.primary,
//       //       //     ),
//       //       //   ),
//       //       // ),
//       //       // const SizedBox(height: 20),
//       //       // const Text("Total Hitungan:"),
//       //       // Text('${_controller.value}', style: const TextStyle(fontSize: 40)),

//       //       // const SizedBox(height: 5),

//       //       // const Text("Masukkan nilai Step:"),
//       //       // SizedBox(
//       //       //   width: 200,
//       //       //   child: TextField(
//       //       //     textAlign: TextAlign.center,
//       //       //     keyboardType: TextInputType.number,
//       //       //     onChanged: (value) {
//       //       //       final step = int.tryParse(value);
//       //       //       if (step != null && step > 0) {
//       //       //         setState(() => _controller.newStep(step, widget.username));
//       //       //       }
//       //       //     },
//       //       //     decoration: const InputDecoration(
//       //       //       border: OutlineInputBorder(),
//       //       //       hintText: '(batas 1-100000)',
//       //       //     ),
//       //       //   ),
//       //       // ),

//       //       // Text(
//       //       //   'Nilai step : ${_controller.step}',
//       //       //   style: const TextStyle(fontSize: 20),
//       //       // ),

//       //       // const SizedBox(height: 10),

//       //       // const Text("Riwayat Aktivitas:"),
//       //       // Expanded(
//       //       //   child: ListView.builder(
//       //       //     itemCount: _controller.recentHistory.length,
//       //       //     itemBuilder: (context, index) {
//       //       //       String item = _controller.recentHistory[index];

//       //       //       Color textColor = Colors.black;
//       //       //       if (item.contains("increment")) {
//       //       //         textColor = Colors.green;
//       //       //       } else if (item.contains("decrement")) {
//       //       //         textColor = Colors.red;
//       //       //       } else if (item.contains("reset")) {
//       //       //         textColor = Colors.orange;
//       //       //       }

//       //       //       return ListTile(
//       //       //         textColor: textColor,
//       //       //         title: Text(_controller.recentHistory[index]),
//       //       //       );
//       //       //     },
//       //       //   ),
//       //       // ),
//       //     ],
//       //   ),
//       // ),
//       // floatingActionButton: Row(
//       //   mainAxisSize: MainAxisSize.min,
//       //   children: [
//       //     FloatingActionButton(
//       //       onPressed: () => setState(() {
//       //         _controller.increment(widget.username);
//       //       }),
//       //       tooltip: 'Increment',
//       //       child: const Icon(Icons.add),
//       //       foregroundColor: Colors.green,
//       //       backgroundColor: Colors.white,
//       //     ),

//       //     const SizedBox(width: 15),
//       //     FloatingActionButton(
//       //       onPressed: () => setState(() {
//       //         _controller.decrement(widget.username);
//       //       }),
//       //       tooltip: 'Decrement',
//       //       child: const Icon(Icons.remove),
//       //       foregroundColor: Colors.red,
//       //       backgroundColor: Colors.white,
//       //     ),

//       //     const SizedBox(width: 15),
//       //     FloatingActionButton(
//       //       onPressed: () => _confirmReset(),
//       //       tooltip: 'Reset',
//       //       child: const Icon(Icons.refresh),
//       //       foregroundColor: Colors.orange,
//       //       backgroundColor: Colors.white,
//       //     ),

//       //     const SizedBox(width: 15),
//       //     FloatingActionButton(
//       //       onPressed: () => setState(() {
//       //         _controller.clearHistory();
//       //         _showSnackBar('Riwayat aktivitas telah dihapus');
//       //       }),
//       //       tooltip: 'Clear History',
//       //       child: const Icon(Icons.delete),
//       //       foregroundColor: Colors.black,
//       //       backgroundColor: Colors.white,
//       //     ),
//       //   ],
//       // ),
//     );
//   }
// }
