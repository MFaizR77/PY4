import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/features/logbook/log_controller.dart';
import 'package:logbook_app_001/features/logbook/widgets/app_snackbar.dart';

class LogEditorPage extends StatefulWidget {
  final LogModel? log;
  final int? index;
  final LogController controller;
  final dynamic currentUser;

  const LogEditorPage({
    super.key,
    this.log,
    this.index,
    required this.controller,
    required this.currentUser,
  });

  @override
  State<LogEditorPage> createState() => _LogEditorPageState();
}

class _LogEditorPageState extends State<LogEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  String _selectedCategory = 'Mechanical';
  bool _isPublic = false;
  final List<String> _categories = ['Mechanical', 'Electronic', 'Software'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.log?.title ?? '');
    _descController = TextEditingController(text: widget.log?.description ?? '');
    _selectedCategory = widget.log?.category ?? 'Mechanical';
    _isPublic = widget.log?.isPublic ?? false;

    _descController.addListener(() {
      setState(() {});
    });
  }

  void _save() {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      showAppSnackbar(
        context,
        'Judul dan deskripsi tidak boleh kosong!',
        SnackbarType.error,
      );
      return;
    }

    if (widget.log == null) {
      widget.controller.addLog(
        title,
        desc,
        widget.currentUser['uid'],
        widget.currentUser['teamId'],
        _selectedCategory,
        _isPublic,
      );
      showAppSnackbar(
        context,
        'Catatan berhasil ditambahkan!',
        SnackbarType.success,
      );
    } else {
      widget.controller.updateLog(
        widget.index!,
        title,
        desc,
        _selectedCategory,
        _isPublic,
      );
      showAppSnackbar(
        context,
        'Catatan berhasil diperbarui!',
        SnackbarType.success,
      );
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.log == null ? 'Catatan Baru' : 'Edit Catatan'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Editor'),
              Tab(text: 'Pratinjau'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _save,
              tooltip: 'Simpan',
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildEditorTab(),
            _buildPreviewTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Judul Catatan',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Kategori',
              border: OutlineInputBorder(),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value ?? 'Other';
              });
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Visibilitas Catatan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _isPublic ? 'Public - Semua anggota tim bisa lihat' : 'Private - Hanya Anda yang bisa lihat',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Switch(
                  value: _isPublic,
                  onChanged: (value) {
                    setState(() {
                      _isPublic = value;
                    });
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _descController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: 'Tulis laporan dengan format Markdown...\n\n'
                    'Contoh:\n# Judul\n**Tebal**\n*Italic*\n- List\n```kode```',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewTab() {
    return Markdown(
      data: _descController.text.isEmpty 
          ? '*Tidak ada konten untuk ditampilkan*' 
          : _descController.text,
      selectable: true,
      padding: const EdgeInsets.all(16),
    );
  }
}
