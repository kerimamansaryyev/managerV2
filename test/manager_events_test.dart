import 'package:manager/src/models/task_event.dart';
import 'package:test/test.dart';
import 'utils/test_manager_events.dart' as event_utils;

void main() {
  group('Testing .on method', () {});
  group('Testing synchronous tasks - ', () {
    test('Synchronous tasks are executed in order that they were called', () {
      final manager = event_utils.TestCountManager(0);
      expectLater(manager.onStateChanged, emitsInOrder([1, 2, 3, emitsDone]));
      manager.run(event_utils.TestCounterSyncValueTask(value: 1, id: '1'));
      manager.run(event_utils.TestCounterSyncValueTask(value: 2, id: '1'));
      manager.run(event_utils.TestCounterSyncValueTask(value: 3, id: '1'));
      manager.dispose();
    });

    test('Manager emits only success events when running synchronous tasks',
        () {
      final manager = event_utils.TestCountManager(0);
      expectLater(
          manager
              .on<event_utils.TestCounterSyncValueTask>()
              .map((event) => event.runtimeType),
          emitsInOrder([
            TaskSuccessEvent<int>,
            TaskSuccessEvent<int>,
            TaskSuccessEvent<int>,
            emitsDone
          ]));
      expectLater(
          manager
              .on<event_utils.TestCounterSyncValueTask>()
              .map((event) => event.task.id),
          emitsInOrder(['one', 'two', 'three', emitsDone]));
      manager.run(event_utils.TestCounterSyncValueTask(value: 1, id: 'one'));
      manager.run(event_utils.TestCounterSyncValueTask(value: 2, id: 'two'));
      manager.run(event_utils.TestCounterSyncValueTask(value: 3, id: 'three'));
      manager.dispose();
    });
  });
}
