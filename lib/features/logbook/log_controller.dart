import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart' as hive;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/services/mongo_service.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';
import 'package:logbook_app_001/services/access_control_service.dart';
import 'package:logbook_app_001/services/connection_service.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  late hive.Box<LogModel> _myBox;
  String _currentUserId = '';
  String _currentUserRole = 'Member';
  String _currentTeamId = '';
  StreamSubscription? _connectionSubscription;
  bool _isInitialized = false;

  LogController() {
    _initHive();
  }

  Future<void> _initHive() async {
    _myBox = hive.Hive.box<LogModel>('offline_logs');
    _isInitialized = true;
  }

  void startListeningConnection() {
    if (_connectionSubscription != null) return;
    _connectionSubscription = ConnectionService().onConnectionRestored.listen((_) {
      _syncPendingLogs();
    });
  }

  Future<void> _syncPendingLogs() async {
    if (!_isInitialized) return;
    
    final allLogsInBox = _myBox.values.toList();
    final pendingLogs = allLogsInBox.where((log) => log.id == null || log.id!.isEmpty).toList();
    
    if (pendingLogs.isEmpty) {
      await LogHelper.writeLog('SYNC: Tidak ada data pending untuk disinkronkan', source: 'log_controller.dart');
      return;
    }

    await LogHelper.writeLog('SYNC: Menemukan ${pendingLogs.length} data pending, memulai sinkronisasi...', source: 'log_controller.dart');

    for (var log in pendingLogs) {
      try {
        final cloudId = ObjectId().oid;
        final syncedLog = LogModel(
          id: cloudId,
          title: log.title,
          description: log.description,
          date: log.date,
          authorId: log.authorId,
          teamId: log.teamId,
          category: log.category,
          isPublic: log.isPublic,
        );

        await MongoService().insertLog(syncedLog);

        final index = _myBox.values.toList().indexOf(log);
        if (index >= 0) {
          await _myBox.putAt(index, syncedLog);
        }

        await LogHelper.writeLog('SYNC: "${log.title}" berhasil diunggah ke Cloud', source: 'log_controller.dart');
      } catch (e) {
        await LogHelper.writeLog('SYNC ERROR: Gagal sync "${log.title}" - $e', source: 'log_controller.dart', level: 1);
      }
    }

    await loadLogs(_currentTeamId);
  }

  void setUserInfo(String userId, String role, String teamId) {
    _currentUserId = userId;
    _currentUserRole = role;
    _currentTeamId = teamId;
  }

  String get currentUserId => _currentUserId;
  String get currentUserRole => _currentUserRole;

  Future<void> loadLogs(String teamId) async {
    _currentTeamId = teamId;
    
    logsNotifier.value = _myBox.values.where((log) => log.teamId == teamId).toList();

    try {
      final cloudData = await MongoService().getLogs(teamId);
      
      await _myBox.clear();
      for (var log in cloudData) {
        await _myBox.add(log);
      }

      logsNotifier.value = cloudData;
      
      await LogHelper.writeLog(
        'SYNC: Data berhasil diperbarui dari Atlas',
        source: 'log_controller.dart',
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        'OFFLINE: Menggunakan data cache lokal',
        source: 'log_controller.dart',
        level: 3,
      );
    }
  }

  Future<void> addLog(
    String title,
    String desc,
    String authorId,
    String teamId,
    String category,
    bool isPublic,
  ) async {
    final newLog = LogModel(
      id: null,
      title: title,
      description: desc,
      date: DateTime.now().toIso8601String(),
      authorId: authorId,
      teamId: teamId,
      category: category,
      isPublic: isPublic,
    );

    await _myBox.add(newLog);
    final updatedList = [...logsNotifier.value, newLog];
    logsNotifier.value = updatedList;

    if (ConnectionService().isConnected) {
      try {
        final cloudId = ObjectId().oid;
        final cloudLog = LogModel(
          id: cloudId,
          title: title,
          description: desc,
          date: DateTime.now().toIso8601String(),
          authorId: authorId,
          teamId: teamId,
          category: category,
          isPublic: isPublic,
        );

        await MongoService().insertLog(cloudLog);

        final index = _myBox.values.toList().indexOf(newLog);
        if (index >= 0) {
          await _myBox.putAt(index, cloudLog);
          logsNotifier.value = [...logsNotifier.value];
          logsNotifier.value = _myBox.values.where((log) => log.teamId == _currentTeamId).toList();
        }

        await LogHelper.writeLog(
          'SUCCESS: Data tersinkron ke Cloud',
          source: 'log_controller.dart',
        );
      } catch (e) {
        await LogHelper.writeLog(
          'WARNING: Data tersimpan lokal, akan sinkron saat online',
          source: 'log_controller.dart',
          level: 1,
        );
      }
    } else {
      await LogHelper.writeLog(
        'OFFLINE: Data tersimpan lokal (belum sync)',
        source: 'log_controller.dart',
        level: 3,
      );
    }
  }

  Future<void> updateLog(int index, String title, String desc, String category, bool isPublic) async {
    if (index < 0 || index >= logsNotifier.value.length) {
      await LogHelper.writeLog('ERROR: Index tidak valid', source: 'log_controller.dart', level: 1);
      return;
    }

    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final oldLog = currentLogs[index];

    if (!AccessControlService.canEdit(_currentUserRole, oldLog.authorId, _currentUserId)) {
      await LogHelper.writeLog(
        'SECURITY: Unauthorized edit attempt',
        source: 'log_controller.dart',
        level: 1,
      );
      return;
    }

    final updatedLog = LogModel(
      id: oldLog.id,
      title: title,
      description: desc,
      date: DateTime.now().toIso8601String(),
      authorId: oldLog.authorId,
      teamId: oldLog.teamId,
      category: category,
      isPublic: isPublic,
    );

    await _myBox.putAt(index, updatedLog);
    currentLogs[index] = updatedLog;
    logsNotifier.value = currentLogs;

    try {
      await MongoService().updateLog(updatedLog);
      await LogHelper.writeLog(
        'SUCCESS: Update "${oldLog.title}" berhasil',
        source: 'log_controller.dart',
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        'ERROR: Gagal sinkronisasi Update - $e',
        source: 'log_controller.dart',
        level: 1,
      );
    }
  }

  Future<void> removeLog(int index) async {
    if (index < 0 || index >= logsNotifier.value.length) {
      await LogHelper.writeLog('ERROR: Index tidak valid', source: 'log_controller.dart', level: 1);
      return;
    }

    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final targetLog = currentLogs[index];

    if (!AccessControlService.canDelete(_currentUserRole, targetLog.authorId, _currentUserId)) {
      await LogHelper.writeLog(
        'SECURITY: Unauthorized delete attempt',
        source: 'log_controller.dart',
        level: 1,
      );
      return;
    }

    try {
      if (targetLog.id != null && targetLog.id!.isNotEmpty) {
        await MongoService().deleteLog(ObjectId.fromHexString(targetLog.id!));
      }

      await _myBox.deleteAt(index);
      currentLogs.removeAt(index);
      logsNotifier.value = currentLogs;

      await LogHelper.writeLog(
        'SUCCESS: Hapus "${targetLog.title}" berhasil',
        source: 'log_controller.dart',
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        'ERROR: Gagal sinkronisasi Hapus - $e',
        source: 'log_controller.dart',
        level: 1,
      );
    }
  }

  void dispose() {
    _connectionSubscription?.cancel();
  }
}
