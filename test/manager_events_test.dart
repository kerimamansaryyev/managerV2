import 'package:manager/src/models/task_event.dart';
import 'package:test/test.dart';
import 'utils/test_manager_events.dart' as event_utils;

void main() {
  group('Testing asynchronous tasks - ', () {
    test('Events with a different id are executed concurrently', () async {
      final manager = event_utils.TestCountManager(0);
      expectLater(
          manager.on().map((event) => '${event.runtimeType}_${event.task.id}'),
          emitsInOrder([
            '${TaskLoadingEvent<int>}_one',
            '${TaskLoadingEvent<int>}_two',
            '${TaskSuccessEvent<int>}_one',
            '${TaskSuccessEvent<int>}_two',
            '${TaskLoadingEvent<int>}_one',
            '${TaskLoadingEvent<int>}_two',
            '${TaskSuccessEvent<int>}_two',
            '${TaskSuccessEvent<int>}_one',
          ]));
      manager.run(event_utils.TestCounterAsyncValueTask0(
          id: 'one', value: 2, delay: const Duration(seconds: 2)));
      manager.run(event_utils.TestCounterAsyncValueTask0(
          id: 'two', value: 2, delay: const Duration(seconds: 2)));
      await Future.delayed(const Duration(seconds: 2));
      manager.run(event_utils.TestCounterAsyncValueTask0(
          id: 'one', value: 2, delay: const Duration(seconds: 2)));
      manager.run(event_utils.TestCounterAsyncValueTask0(
          id: 'two', value: 2, delay: null));
    });
    test('Events with the same id are ommited and subtracted to 1', () async {
      final manager = event_utils.TestCountManager(0);
      expectLater(
          manager.on().map((event) => '${event.runtimeType}_${event.task.id}'),
          emitsInOrder([
            '${TaskLoadingEvent<int>}_one',
            '${TaskLoadingEvent<int>}_one',
            '${TaskLoadingEvent<int>}_one',
            '${TaskSuccessEvent<int>}_one',
          ]));
      manager.run(event_utils.TestCounterAsyncValueTask0(
          id: 'one', value: 2, delay: const Duration(seconds: 2)));
      manager.run(event_utils.TestCounterAsyncValueTask1(
          id: 'one', value: 2, delay: const Duration(seconds: 2)));
      await Future.delayed(const Duration(seconds: 1));
      manager.run(event_utils.TestCounterAsyncValueTask0(
          id: 'one', value: 2, delay: const Duration(seconds: 2)));
    });
  });
  group('Testing .on method - ', () {
    test('Stream must give all events if neither the type parameter nor id set',
        () {
      final manager = event_utils.TestCountManager(0);
      expectLater(
          manager
              .on()
              .where((event) => event is TaskSuccessEvent)
              .map((event) => event.task.id),
          emitsInOrder(['one', 'two', 'three', emitsDone]));
      manager.run(event_utils.TestCounterSyncValueTask(id: 'one', value: 2));
      manager.run(event_utils.TestCounterSyncValueTask(id: 'two', value: 2));
      manager.run(event_utils.TestCounterSyncValueTask1(id: 'three', value: 2));
      manager.dispose();
    });
    test('Stream must give all events of provided type independent of id', () {
      final manager = event_utils.TestCountManager(0);
      expectLater(
          manager
              .on<event_utils.TestCounterSyncValueTask>()
              .where((event) => event is TaskSuccessEvent)
              .map((event) => event.task.id),
          emitsInOrder(['one', 'two', emitsDone]));
      manager.run(event_utils.TestCounterSyncValueTask(id: 'one', value: 2));
      manager.run(event_utils.TestCounterSyncValueTask(id: 'two', value: 2));
      manager.run(event_utils.TestCounterSyncValueTask1(id: 'three', value: 2));
      manager.dispose();
    });

    test('Stream must give all events of provided taskId independent of type',
        () {
      final manager = event_utils.TestCountManager(0);
      expectLater(
          manager
              .on(taskId: 'one')
              .where((event) => event is TaskSuccessEvent)
              .map((event) => event.task.id),
          emitsInOrder(['one', emitsDone]));
      manager.run(event_utils.TestCounterSyncValueTask(id: 'one', value: 2));
      manager.run(event_utils.TestCounterSyncValueTask(id: 'two', value: 2));
      manager.run(event_utils.TestCounterSyncValueTask1(id: 'three', value: 2));
      manager.dispose();
    });

    test('Stream must give all events that satisfies bot type and id', () {
      final manager = event_utils.TestCountManager(0);
      expectLater(
          manager
              .on<event_utils.TestCounterSyncValueTask>(taskId: 'two')
              .where((event) => event is TaskSuccessEvent)
              .map((event) => event.task.id),
          emitsInOrder(['two', emitsDone]));
      manager.run(event_utils.TestCounterSyncValueTask(id: 'one', value: 2));
      manager.run(event_utils.TestCounterSyncValueTask(id: 'two', value: 2));
      manager.run(event_utils.TestCounterSyncValueTask1(id: 'three', value: 2));
      manager.dispose();
    });

    test(
        'Stream will not give events that does not satisfy both type and taskId',
        () {
      final manager = event_utils.TestCountManager(0);
      expectLater(
          manager
              .on<event_utils.TestCounterSyncValueTask>(taskId: 'four')
              .where((event) => event is TaskSuccessEvent)
              .map((event) => event.task.id),
          emitsInOrder([emitsDone]));
      manager.run(event_utils.TestCounterSyncValueTask(id: 'one', value: 2));
      manager.run(event_utils.TestCounterSyncValueTask(id: 'two', value: 2));
      manager.run(event_utils.TestCounterSyncValueTask1(id: 'three', value: 2));
      manager.dispose();
    });
  });

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
