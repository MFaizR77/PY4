import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logbook_app_001/features/logbook/counter_controller.dart' show CounterController;

void main() {
  group('Module 1 - CounterController (White Box Testing)', () {
    late CounterController controller;
    const username = "admin";

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      controller = CounterController();
      controller.setUsername(username);
      await controller.loadCounter();
    });

    test('TC01: Initial value should be 0', () {
      expect(controller.value, 0);
    });

    test('TC02: setStep (newStep) should change step value to 5', () {
      controller.newStep(5, username);
      expect(controller.step, 5);
    });

    test('TC03: newStep should ignore negative value', () {
      controller.newStep(3, username);
      controller.newStep(-1, username);
      expect(controller.step, 3);
    });

    test('TC04: newStep should cap at 100000', () {
      controller.newStep(200000, username);
      expect(controller.step, 100000);
    });

    test('TC05: newStep should accept value between 1 and 100000', () {
      controller.newStep(50000, username);
      expect(controller.step, 50000);
    });

    test('TC06: increment should increase counter based on step', () {
      controller.newStep(2, username);
      controller.increment(username);
      expect(controller.value, 2);
    });

    test('TC07: decrement should decrease counter when counter >= step (Path True)', () {
      controller.newStep(2, username);
      controller.increment(username);
      controller.increment(username);
      controller.decrement(username);
      expect(controller.value, 2);
    });

    test('TC08: decrement should set counter to 0 when counter < step (Path False)', () {
      controller.newStep(5, username);
      controller.decrement(username);
      expect(controller.value, 0);
    });

    test('TC09: reset should set counter to zero', () {
      controller.increment(username);
      controller.reset(username);
      expect(controller.value, 0);
    });

    test('TC10: history should record increment action', () {
      controller.newStep(1, username);
      controller.increment(username);
      expect(controller.history.isNotEmpty, true);
      expect(controller.history.last.contains('increment'), true);
    });

    test('TC11: history should not exceed 5 items', () async {
      controller.newStep(1, username);
      for (int i = 0; i < 6; i++) {
        controller.increment(username);
      }
      expect(controller.history.length, 5);
    });

    test('TC12: clearHistory should remove all history', () {
      controller.increment(username);
      controller.clearHistory();
      expect(controller.history.isEmpty, true);
    });

    test('TC13: recentHistory should return reversed history', () {
      controller.newStep(1, username);
      controller.increment(username);
      controller.increment(username);
      final recent = controller.recentHistory;
      expect(recent.first, controller.history.last);
    });

    test('TC14: decrement should not go below zero', () {
      controller.newStep(10, username);
      controller.decrement(username);
      expect(controller.value, 0);
    });

    test('TC15: counter should persist after save and load', () async {
      controller.newStep(3, username);
      controller.increment(username);
      
      final newController = CounterController();
      newController.setUsername(username);
      await newController.loadCounter();
      
      expect(newController.value, 3);
    });
  });
}
