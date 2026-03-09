import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/onboarding/onboarding_view.dart';
import 'package:logbook_app_001/features/logbook/log_controller.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/features/logbook/widgets/greeting_header.dart';
import 'package:logbook_app_001/features/logbook/widgets/app_snackbar.dart';
import 'package:logbook_app_001/features/logbook/log_editor_page.dart';
import 'package:logbook_app_001/services/mongo_service.dart';
import 'package:logbook_app_001/services/connection_service.dart';
import 'package:logbook_app_001/services/access_control_service.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';
import 'package:logbook_app_001/helpers/date_time_helper.dart';

class LogView extends StatefulWidget {
  final dynamic currentUser;

  const LogView({super.key, required this.currentUser});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late LogController _controller;
  List<LogModel> _filteredLogs = [];
  String _searchQuery = "";
  bool _isLoading = true;
  late ConnectionService _connectionService;
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    _controller = LogController();
    _controller.setUserInfo(
      widget.currentUser['uid'] ?? 'unknown',
      widget.currentUser['role'] ?? 'Member',
      widget.currentUser['teamId'] ?? 'no_team',
    );
    _connectionService = ConnectionService();
    _connectionService.init();
    _controller.startListeningConnection();

    _filteredLogs = _controller.logsNotifier.value;

    _controller.logsNotifier.addListener(() {
      _applyFilter(_searchQuery);
    });

    _connectionService.isConnectedNotifier.addListener(_onConnectionChanged);

    Future.microtask(() => _initDatabase());
  }

  void _onConnectionChanged() {
    final isConnected = _connectionService.isConnectedNotifier.value;

    if (!isConnected) {
      _wasOffline = true;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Tidak ada koneksi internet. Mode Offline.'),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else if (_wasOffline && isConnected) {
      _wasOffline = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Koneksi internet kembali. Menyinkronkan data...'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _controller.startListeningConnection();
        _refreshData();
      }
    }
  }

  Future<void> _refreshData() async {
    await _controller.loadLogs(widget.currentUser['teamId'] ?? 'no_team');
  }

  Future<void> _initDatabase() async {
    setState(() => _isLoading = true);
    try {
      await LogHelper.writeLog(
        "UI: Memulai inisialisasi database...",
        source: "log_view.dart",
      );

      await MongoService().connect().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception(
          "Koneksi Cloud Timeout. Periksa sinyal/IP Whitelist.",
        ),
      );

      await _controller.loadLogs(widget.currentUser['teamId'] ?? 'no_team');

      await LogHelper.writeLog(
        "UI: Data berhasil dimuat ke Notifier.",
        source: "log_view.dart",
      );
    } catch (e) {
      await LogHelper.writeLog(
        "UI: Error - $e",
        source: "log_view.dart",
        level: 1,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Masalah: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToEditor({LogModel? log, int? index}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogEditorPage(
          log: log,
          index: index,
          controller: _controller,
          currentUser: widget.currentUser,
        ),
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
              _controller.removeLog(index);
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
          content: Text('Apakah Anda yakin ingin logout, ${widget.currentUser['username']}?'),
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
    final allLogs = _controller.logsNotifier.value;
    final currentUserId = widget.currentUser['uid'] ?? 'unknown';

    setState(() {
      List<LogModel> visibleLogs = allLogs.where((log) {
        final isOwner = log.authorId == currentUserId;
        final isPublic = log.isPublic == true;
        return isOwner || isPublic;
      }).toList();

      if (query.isEmpty) {
        _filteredLogs = visibleLogs;
      } else {
        _filteredLogs = visibleLogs.where((log) {
          return log.title.toLowerCase().contains(query.toLowerCase()) ||
              log.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Color _colorCategory(String category) {
    switch (category) {
      case "Work":
        return Colors.yellow;
      case "Personal":
        return Colors.green;
      case "Study":
        return Colors.orange;
      case "Other":
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  Color _textColorForCategory(String category) {
    return Colors.black;
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
    final currentUserId = widget.currentUser['uid'] ?? 'unknown';
    final currentUserRole = widget.currentUser['role'] ?? 'Member';

    return Scaffold(
      appBar: AppBar(
        title: Text("LogBook: ${widget.currentUser['username']}"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
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

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              GreetingHeader(username: widget.currentUser['username'] ?? 'User').getGreeting() +
                  ", " +
                  (widget.currentUser['username'] ?? 'User') +
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
              valueListenable: _controller.logsNotifier,
              builder: (context, currentLogs, child) {
                if (_isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Menghubungkan ke MongoDB Atlas..."),
                      ],
                    ),
                  );
                }

                if (currentLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text("Belum ada catatan."),
                        ElevatedButton(
                          onPressed: () => _goToEditor(),
                          child: const Text("Buat Catatan Pertama"),
                        ),
                      ],
                    ),
                  );
                }

                if (_filteredLogs.isEmpty) {
                  return const Center(child: Text("Tidak ada hasil."));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    if (_connectionService.isConnected) {
                      await _controller.loadLogs(widget.currentUser['teamId'] ?? 'no_team');
                      if (mounted) {
                        showAppSnackbar(
                          context,
                          "Data berhasil diperbarui!",
                          SnackbarType.success,
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.wifi_off, color: Colors.white),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text('Tidak ada koneksi. Tidak bisa memperbarui data.'),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.orange,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: ListView.builder(
                    itemCount: _filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = _filteredLogs[index];
                      final originalIndex = _controller.logsNotifier.value.indexOf(log);
                      final bool isOwner = log.authorId == currentUserId;

                    
                      String authorRole = 'Anggota';
                      if (log.authorId.toLowerCase() == 'admin') {
                        authorRole = 'Ketua';
                      } else if (log.authorId.toLowerCase().contains('asisten')) {
                        authorRole = 'Asisten';
                      }

                      final categoryColor = _colorCategory(log.category);

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: 3,
                        color: categoryColor.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: categoryColor, width: 1),
                        ),
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _iconCategory(log.category),
                                color: categoryColor,
                                size: 24,
                              ),
                            ],
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  log.title,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isOwner)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Catatan Saya',
                                    style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                runSpacing: 2,
                                children: [
                                  Icon(Icons.person_outline, size: 12, color: Colors.grey.shade600),
                                  Text(
                                    authorRole,
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                  ),
                                  Text(' • ', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                                  Icon(Icons.access_time, size: 12, color: Colors.grey.shade600),
                                  Text(
                                    DateTimeHelper.formatTimestamp(DateTime.tryParse(log.date) ?? DateTime.now()),
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                  ),
                                  Text(' • ', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                                  Icon(
                                    log.id != null && log.id!.isNotEmpty ? Icons.cloud_done : Icons.cloud_upload_outlined,
                                    size: 12,
                                    color: log.id != null && log.id!.isNotEmpty ? Colors.green : Colors.orange,
                                  ),
                                  Text(
                                    log.id != null && log.id!.isNotEmpty ? 'Online' : 'Offline',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: log.id != null && log.id!.isNotEmpty ? Colors.green : Colors.orange,
                                      fontWeight: log.id != null && log.id!.isNotEmpty ? FontWeight.normal : FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (AccessControlService.canEdit(currentUserRole, log.authorId, currentUserId))
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _goToEditor(log: log, index: originalIndex),
                                ),
                              if (AccessControlService.canDelete(currentUserRole, log.authorId, currentUserId))
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeDialog(originalIndex),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
