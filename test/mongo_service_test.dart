import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_001/services/mongo_service.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('Modul 4 - Save Data to Cloud (MongoDB Integration)', () {
    late MongoService mongoService;
    const testTeamId = 'test_team_integration';

    setUpAll(() async {
      await dotenv.load();
      mongoService = MongoService();
      try {
        await mongoService.connect();
      } catch (e) {
        print('MongoDB connection failed: $e');
      }
    });

    tearDownAll(() async {
      // Cleanup test data
      try {
        final db = await Db.create(dotenv.env['MONGODB_URI']!);
        await db.open();
        final collection = db.collection('logs');
        await collection.remove(where.eq('teamId', testTeamId));
        await db.close();
      } catch (e) {
        print('Cleanup failed: $e');
      }
    });

    test('TC01: Insert log to MongoDB (Path: Online)', () async {
      final testLog = LogModel(
        id: ObjectId().oid,
        title: 'Test Log Cloud',
        description: 'Test Description',
        date: DateTime.now().toIso8601String(),
        authorId: 'test_user',
        teamId: testTeamId,
        category: 'Work',
        isPublic: false,
      );

      try {
        await mongoService.insertLog(testLog);

        final result = await mongoService.getLogs(testTeamId);
        final inserted = result.firstWhere(
          (log) => log.title == 'Test Log Cloud',
          orElse: () => LogModel(
            title: '', description: '', date: '', authorId: '', teamId: '', category: '',
          ),
        );

        expect(inserted.title, 'Test Log Cloud');
        expect(inserted.authorId, 'test_user');
      } catch (e) {
        print('Insert test failed: $e');
        fail('MongoDB insert failed: $e');
      }
    });

    test('TC02: Get logs from MongoDB', () async {
      try {
        final result = await mongoService.getLogs(testTeamId);

        expect(result, isA<List<LogModel>>());
        expect(result.isNotEmpty, true);
        expect(result.any((log) => log.teamId == testTeamId), true);
      } catch (e) {
        print('Get test failed: $e');
        fail('MongoDB get failed: $e');
      }
    });

    test('TC03: Update log in MongoDB', () async {
      try {
        // Insert first
        final logId = ObjectId().oid;
        final testLog = LogModel(
          id: logId,
          title: 'Update Test',
          description: 'Original',
          date: DateTime.now().toIso8601String(),
          authorId: 'test_user',
          teamId: testTeamId,
          category: 'Work',
        );

        await mongoService.insertLog(testLog);

        // Update
        final updatedLog = LogModel(
          id: logId,
          title: 'Update Test',
          description: 'Updated Description',
          date: DateTime.now().toIso8601String(),
          authorId: 'test_user',
          teamId: testTeamId,
          category: 'Personal',
        );

        await mongoService.updateLog(updatedLog);

        // Verify
        final result = await mongoService.getLogs(testTeamId);
        final found = result.firstWhere(
          (log) => log.id == logId,
          orElse: () => LogModel(
            title: '', description: '', date: '', authorId: '', teamId: '', category: '',
          ),
        );

        expect(found.description, 'Updated Description');
        expect(found.category, 'Personal');
      } catch (e) {
        print('Update test failed: $e');
        fail('MongoDB update failed: $e');
      }
    });
  });
}
