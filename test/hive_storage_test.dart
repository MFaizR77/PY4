import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'dart:async';

void main() {
  group('Modul 3 - Save Data to Disk (Hive)', () {
    late Box<LogModel> testBox;

    setUp(() async {
      Hive.init('./test_hive');
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(LogModelAdapter());
      }
      testBox = await Hive.openBox<LogModel>('test_logs');
    });

    tearDown(() async {
      await testBox.clear();
      await testBox.close();
    });

    test('TC01: Save log to Hive local storage', () async {
      final log = LogModel(
        id: null,
        title: 'Test Title',
        description: 'Test Description',
        date: DateTime.now().toIso8601String(),
        authorId: 'user1',
        teamId: 'team1',
        category: 'Work',
      );

      await testBox.add(log);

      expect(testBox.values.isNotEmpty, true);
      expect(testBox.values.first.title, 'Test Title');
    });

    test('TC02: Load logs from Hive local storage', () async {
      await testBox.add(LogModel(
        id: '1',
        title: 'Existing Log',
        description: 'Description',
        date: DateTime.now().toIso8601String(),
        authorId: 'user1',
        teamId: 'team1',
        category: 'Work',
      ));

      final logs = testBox.values.where((log) => log.teamId == 'team1').toList();

      expect(logs.isNotEmpty, true);
      expect(logs.first.title, 'Existing Log');
    });

    test('TC03: Update log in Hive local storage', () async {
      await testBox.add(LogModel(
        id: null,
        title: 'Original',
        description: 'Original Desc',
        date: DateTime.now().toIso8601String(),
        authorId: 'user1',
        teamId: 'team1',
        category: 'Work',
      ));

      await testBox.putAt(0, LogModel(
        id: null,
        title: 'Updated',
        description: 'New Desc',
        date: DateTime.now().toIso8601String(),
        authorId: 'user1',
        teamId: 'team1',
        category: 'Personal',
      ));

      expect(testBox.values.first.title, 'Updated');
    });
  });
}
