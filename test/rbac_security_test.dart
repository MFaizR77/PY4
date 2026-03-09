import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/services/access_control_service.dart';

void main() {
  group('RBAC Security Check: Private logs should NOT be visible to teammates', () {
    
    test('User B should only see public logs from User A', () {
      // 1. Setup Data:
      // User A memiliki 2 catatan: 1 berstatus 'Private' dan 1 berstatus 'Public'.
      final userAId = 'user_a_123';
      final userBId = 'user_b_456';
      final teamId = 'MEKTRA_KLP_01';

      final logsFromCloud = [
        LogModel(
          id: 'log_001',
          title: 'Catatan Private User A',
          description: 'Ini catatan pribadi',
          date: DateTime.now().toIso8601String(),
          authorId: userAId,
          teamId: teamId,
          category: 'Work',
          isPublic: false, // Private - seharusnya TIDAK terlihat oleh User B
        ),
        LogModel(
          id: 'log_002',
          title: 'Catatan Public User A',
          description: 'Ini catatan publik',
          date: DateTime.now().toIso8601String(),
          authorId: userAId,
          teamId: teamId,
          category: 'Work',
          isPublic: true, // Public - seharusnya TAMPIL untuk User B
        ),
      ];

      // 2. Action:
      // User B (rekan satu tim User A) melakukan fungsi fetchLogs() / filter visibility.
      
      // Simulasi filter visibilitas yang ada di LogView._applyFilter()
      final currentUserId = userBId;
      final visibleLogs = logsFromCloud.where((log) {
        final isOwner = log.authorId == currentUserId;
        final isPublic = log.isPublic == true;
        return isOwner || isPublic;
      }).toList();

      // 3. Assert (Validasi):
      // Pastikan List data yang diterima User B hanya berisi 1 log (hanya yang Public).
      // Jika log Private muncul, maka sistem dinyatakan gagal (Vulnerable).
      expect(visibleLogs.length, equals(1), 
        reason: 'User B hanya boleh melihat 1 log publik');
      
      expect(visibleLogs.first.title, equals('Catatan Public User A'),
        reason: 'Log yang terlihat harus yang berstatus Public');
      
      expect(visibleLogs.any((log) => log.isPublic == false), isFalse,
        reason: 'Log Private TIDAK boleh terlihat oleh User B - VULNERABLE jika ini terjadi!');
    });

    test('Owner should see both private and public logs', () {
      // User A harus bisa melihat kedua catatannya (Private + Public)
      final userAId = 'user_a_123';
      final teamId = 'MEKTRA_KLP_01';

      final logsFromCloud = [
        LogModel(
          id: 'log_001',
          title: 'Catatan Private',
          description: 'Pribadi',
          date: DateTime.now().toIso8601String(),
          authorId: userAId,
          teamId: teamId,
          category: 'Work',
          isPublic: false,
        ),
        LogModel(
          id: 'log_002',
          title: 'Catatan Public',
          description: 'Publik',
          date: DateTime.now().toIso8601String(),
          authorId: userAId,
          teamId: teamId,
          category: 'Work',
          isPublic: true,
        ),
      ];

      // User A (pemilik) akses catatannya sendiri
      final visibleLogs = logsFromCloud.where((log) {
        final isOwner = log.authorId == userAId;
        final isPublic = log.isPublic == true;
        return isOwner || isPublic;
      }).toList();

      expect(visibleLogs.length, equals(2),
        reason: 'Pemilik harus melihat semua catatannya (Private + Public)');
    });

    test('Chairman should NOT edit/delete other members private logs', () {
      // Ketua TIDAK boleh mengedit/menghapus catatan private anggota lain
      final chairmanRole = 'Ketua';
      final userAId = 'user_a_123';
      final chairmanId = 'chairman_999';

      // Pengecekan menggunakan AccessControlService
      final canEdit = AccessControlService.canEdit(chairmanRole, userAId, chairmanId);
      final canDelete = AccessControlService.canDelete(chairmanRole, userAId, chairmanId);

      expect(canEdit, isFalse,
        reason: 'Ketua TIDAK boleh mengedit catatan anggota lain');
      expect(canDelete, isFalse,
        reason: ' Ketua TIDAK boleh menghapus catatan anggota lain');
    });

    test('Owner should be able to edit/delete own logs', () {
      // Pemilik BOLEH mengedit/menghapus catatannya sendiri
      final userRole = 'Anggota';
      final userId = 'user_a_123';

      final canEdit = AccessControlService.canEdit(userRole, userId, userId);
      final canDelete = AccessControlService.canDelete(userRole, userId, userId);

      expect(canEdit, isTrue,
        reason: 'Pemilik BOLEH mengedit catatannya sendiri');
      expect(canDelete, isTrue,
        reason: 'Pemilik BOLEH menghapus catatannya sendiri');
    });

    test('AccessControlService.canView() validation', () {
      // Test fungsi canView dengan berbagai skenario
      final ownerId = 'user_a';
      final otherUserId = 'user_b';
      final chairmanRole = 'Anggota';

      // Kasus 1: Pemilik melihat catatannya sendiri (Private)
      expect(
        AccessControlService.canView(chairmanRole, ownerId, ownerId, false),
        isTrue,
        reason: 'Pemilik boleh melihat catatannya sendiri yang Private',
      );

      // Kasus 2: User lain melihat catatan Public orang lain
      expect(
        AccessControlService.canView(chairmanRole, ownerId, otherUserId, true),
        isTrue,
        reason: 'User lain boleh melihat catatan Public',
      );

      // Kasus 3: User lain melihat catatan Private orang lain
      expect(
        AccessControlService.canView(chairmanRole, ownerId, otherUserId, false),
        isFalse,
        reason: 'User lain TIDAK boleh melihat catatan Private',
      );

      // Kasus 4: Ketua melihat catatan Private anggota
      expect(
        AccessControlService.canView('Ketua', ownerId, otherUserId, false),
        isFalse,
        reason: 'Ketua TIDAK boleh melihat catatan Private anggota',
      );
    });
  });
}
