import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/onboarding/onboarding_view.dart';
import 'package:logbook_app_001/features/logbook/log_controller.dart';
import '../logbook/models/log_model.dart';
import 'package:logbook_app_001/features/logbook/widgets/greeting_header.dart';
import 'package:logbook_app_001/features/logbook/widgets/app_snackbar.dart';

class LogView extends StatefulWidget {
  final String username;

  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _logController = LogController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  List<LogModel> _filteredLogs = [];
  String _searchQuery = "";
  List<String> _categories = ["Work", "Personal", "Study", "Other"];
  String _selectedCategory = "Other";

  @override
  void initState() {
    super.initState();
    _logController.setUsername(widget.username);

    _filteredLogs = _logController.logsNotifier.value;

    _logController.logsNotifier.addListener(() {
      _applyFilter(_searchQuery);
    });
  }

  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Catatan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController),
            TextField(controller: _contentController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              _logController.updateLog(
                index,
                _titleController.text,
                _contentController.text,
                _selectedCategory,
              );
              showAppSnackbar(
                context,
                "Catatan berhasil diperbarui!",
                SnackbarType.success,
              );
              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _removeDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Catatan"),
        content: const Text(
          "Apakah Anda yakin ingin menghapus catatan ini? Tindakan ini tidak dapat dibatalkan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              _logController.removeLog(index);
              showAppSnackbar(
                context,
                "Catatan berhasil dihapus!",
                SnackbarType.success,
              );
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  void _showAddLogDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Catatan Baru"),

        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(hintText: "Judul Catatan"),
                ),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(hintText: "Isi Deskripsi"),
                ),
                const SizedBox(height: 16),

                DropdownButton(
                  value: _selectedCategory,
                  hint: const Text("Pilih Kategori"),
                  isExpanded: true,
                  onChanged: (newValue) {
                    setDialogState(() {
                      _selectedCategory = newValue ?? "";
                    });
                  },
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              // Jalankan fungsi tambah di Controller

              String title = _titleController.text.trim();
              String content = _contentController.text.trim();

              if (title.isEmpty || content.isEmpty) {
                showAppSnackbar(
                  context,
                  "Judul dan deskripsi tidak boleh kosong!",
                  SnackbarType.error,
                );
                return;
              }

              _logController.addLog(
                _titleController.text,
                _contentController.text,
                _selectedCategory,
              );

              // Refresh UI Utama (List di belakang dialog)
              setState(() {});

              showAppSnackbar(
                context,
                "Catatan berhasil ditambahkan!",
                SnackbarType.success,
              );

              // Bersihkan input
              _titleController.clear();
              _contentController.clear();

              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingView()),
      (route) => false,
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: Text('Apakah Anda yakin ingin logout, ${widget.username}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _applyFilter(String query) {
    _searchQuery = query;

    final allLogs = _logController.logsNotifier.value;

    setState(() {
      if (query.isEmpty) {
        _filteredLogs = allLogs;
      } else {
        _filteredLogs = allLogs.where((log) {
          return log.title.toLowerCase().contains(query.toLowerCase()) ||
              log.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
      if (query.contains("work") ||
          query.contains("personal") ||
          query.contains("study") ||
          query.contains("other")) {
        _filteredLogs = allLogs.where((log) {
          return log.category.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Color _colorCategory(String category) {
    Color backgroundColor = Colors.black;
    switch (category) {
      case "Work":
        backgroundColor = Colors.yellow;
      case "Personal":
        backgroundColor = Colors.green;
      case "Study":
        backgroundColor = Colors.orange;
      case "Other":
        backgroundColor = Colors.grey;
      default:
        backgroundColor = Colors.black;
    }
    return backgroundColor;
  }

  Color _textColorForCategory(String category) {
    switch (category) {
      case "Work":
      case "Personal":
      case "Study":
      case "Other":
        return Colors.black;
      default:
        return Colors.white;
    }
  }

  IconData _iconCategory(String category) {
    switch (category) {
      case "Work":
        return Icons.work;
      case "Personal":
        return Icons.person;
      case "Study":
        return Icons.school;
      case "Other":
        return Icons.note;
      default:
        return Icons.note;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LogBook - ${widget.username}"),
        actions: [
          IconButton(
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 16),

          // Welcome Message
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              GreetingHeader(username: widget.username).getGreeting() +
                  ", " +
                  widget.username +
                  "!",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 55,
            width: 250,
            child: TextField(
              style: const TextStyle(
                color: Color(0xff020202),
                fontSize: 20,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
              onChanged: _applyFilter,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xfff1f1f1),
                // Border default
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xffcccccc),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xff4a90e2),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
                hintText: "Search for Items",
                hintStyle: const TextStyle(
                  color: Color(0xffb2b2b2),
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
                prefixIcon: const Icon(Icons.search),
                prefixIconColor: Colors.black,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
            ),
          ),

          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _logController.logsNotifier,
              builder: (context, currentLogs, child) {
                if (currentLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/image/note.jpg',
                          width: 150,
                          height: 150,
                        ),
                        const SizedBox(height: 16),
                        Text("Belum ada catatan. Yuk bikin catatan!"),
                      ],
                    ),
                  );
                }

                if (_filteredLogs.isEmpty) {
                  return const Center(child: Text("Tidak ada hasil."));
                }

                return ListView.builder(
                  itemCount: _filteredLogs.length,
                  itemBuilder: (context, index) {
                    final log = _filteredLogs[index];
                    final originalIndex = _logController.logsNotifier.value
                        .indexOf(log);
                    return Dismissible(
                      key: Key(log.date.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        _logController.removeLog(originalIndex);
                        showAppSnackbar(
                          context,
                          "Catatan dihapus!",
                          SnackbarType.success,
                        );
                      },
                      child: Card(
                        elevation: 3,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        color: _colorCategory(log.category),
                        child: ListTile(
                          leading: Icon(
                            _iconCategory(log.category),
                            color: _textColorForCategory(log.category),
                          ),
                          title: Text(
                            log.title,
                            style: TextStyle(
                              color: _textColorForCategory(log.category),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            log.description,
                            style: TextStyle(
                              color: _textColorForCategory(log.category),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  log.category,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _showEditLogDialog(index, log),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  _removeDialog(index);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
