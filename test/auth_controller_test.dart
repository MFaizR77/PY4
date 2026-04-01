import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_001/features/auth/login_controller.dart';

void main() {
  group('Modul 2 - Authentication (LoginController)', () {
    late LoginController authController;

    setUp(() {
      authController = LoginController();
    });

    test('TC01: Login with valid credentials (Path True)', () {
      final result = authController.login('admin', '123');
      expect(result, true);
    });

    test('TC02: Login with invalid password (Path False)', () {
      final result = authController.login('admin', 'wrong');
      expect(result, false);
    });

    test('TC03: Login with non-existent user (Path False)', () {
      final result = authController.login('unknown', '123');
      expect(result, false);
    });
  });
}
