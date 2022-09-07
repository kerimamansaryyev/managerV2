import 'dart:async';

import 'package:manager/src/models/stream_extensions.dart';
import 'package:manager/src/models/task.dart';
import 'package:manager/src/models/task_event.dart';
import 'package:test/test.dart';
import 'utils/test_manager_events.dart' as event_utils;

/// It's okay to ignore the rule for tests
// ignore: long-method
void main() {
  test('Ensuring .onEventCallback is fired', () async {
    var eventCount = 0;
    final manager = event_utils.TestCountManager(
      0,
      onEventCallbackFunction: () => eventCount++,
    );
    manager.run(
      event_utils.TestCounterAsyncValueTask0(
        id: 'one',
        value: 2,
        delay: const Duration(seconds: 2),
      ),
    );
    await manager.waitForTaskToBeDone(taskId: 'one');
    expect(eventCount, 2);
  });

  test('onUpdate must be fired whenever an event occurs or state is changed',
      () async {
    final manager = event_utils.TestCountManager(0);
    int eventCount = 0;
    unawaited(expectLater(manager.onUpdated, emitsThrough(emitsDone)));
    manager.onUpdated.listen((event) {
      eventCount++;
    });
    manager.run(
      event_utils.TestCounterAsyncValueTask0(
        id: 'one',
        value: 2,
        delay: const Duration(seconds: 2),
      ),
    );
    await manager.waitForTaskToBeDone(taskId: 'one');
    manager.dispose();
    expect(eventCount, 3);
  });
  group('Testing asynchronous tasks - ', () {
    test('Events with a different id are executed concurrently', () async {
      final manager = event_utils.TestCountManager(0);
      unawaited(
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
          ]),
        ),
      );
      manager.run(
        event_utils.TestCounterAsyncValueTask0(
          id: 'one',
          value: 2,
          delay: const Duration(seconds: 2),
        ),
      );
      manager.run(
        event_utils.TestCounterAsyncValueTask0(
          id: 'two',
          value: 2,
          delay: const Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      manager.run(
        event_utils.TestCounterAsyncValueTask0(
          id: 'one',
          value: 2,
          delay: const Duration(seconds: 2),
        ),
      );
      manager.run(
        event_utils.TestCounterAsyncValueTask0(
          id: 'two',
          value: 2,
          delay: null,
        ),
      );
    });
    test('Events with the same id are ommited and subtracted to 1', () async {
      final manager = event_utils.TestCountManager(0);
      unawaited(
        expectLater(
          manager.on().map((event) => '${event.runtimeType}_${event.task.id}'),
          emitsInOrder([
            '${TaskLoadingEvent<int>}_one',
            '${TaskLoadingEvent<int>}_one',
            '${TaskLoadingEvent<int>}_one',
            '${TaskSuccessEvent<int>}_one',
          ]),
        ),
      );
      manager.run(
        event_utils.TestCounterAsyncValueTask0(
          id: 'one',
          value: 2,
          delay: const Duration(seconds: 2),
        ),
      );
      manager.run(
        event_utils.TestCounterAsyncValueTask1(
          id: 'one',
          value: 2,
          delay: const Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(seconds: 1));
      manager.run(
        event_utils.TestCounterAsyncValueTask0(
          id: 'one',
          value: 2,
          delay: const Duration(seconds: 2),
        ),
      );
    });

    test(
        'Nested call of an event with the same id will dismiss itself from mutating the state and prevent the further success event',
        () async {
      final manager = event_utils.TestCountManager(0);
      final firstLevelEmitValue = 3;
      final secondLevelEmitValue = 2;
      unawaited(
        expectLater(manager.onStateChanged, neverEmits(firstLevelEmitValue)),
      );
      unawaited(
        expectLater(
          manager.on().map((event) => '${event.runtimeType}_${event.task.id}'),
          emitsInOrder([
            '${TaskLoadingEvent<int>}_one',
            '${TaskLoadingEvent<int>}_one',
            '${TaskSuccessEvent<int>}_one',
          ]),
        ),
      );
      manager.run(
        event_utils.TestCounterAsyncGenericTask(
          id: 'one',
          runFunction: () async {
            await Future.delayed(const Duration(seconds: 2));
            manager.run(
              event_utils.TestCounterAsyncGenericTask(
                runFunction: () async {
                  await Future.delayed(const Duration(seconds: 2));
                  return secondLevelEmitValue;
                },
                id: 'one',
              ),
            );
            return firstLevelEmitValue;
          },
        ),
      );
      await Future.delayed(const Duration(seconds: 5));
      manager.dispose();
    });
  });
  group('Testing .on method - ', () {
    test(
        'Stream will give events only after listening. But if you add withLatest: true, it will instantly fire the latest event',
        () {
      final manager = event_utils.TestCountManager(0);
      manager.run(event_utils.TestCounterSyncValueTask(id: 'one', value: 2));
      expectLater(
        manager
            .on()
            .where((event) => event is TaskSuccessEvent)
            .map((event) => event.task.id),
        emitsInOrder(['two', 'three', emitsDone]),
      );
      expectLater(
        manager
            .on(withLatest: true)
            .where((event) => event is TaskSuccessEvent)
            .map((event) => event.task.id),
        emitsInOrder(['one', 'two', 'three', emitsDone]),
      );
      manager.run(event_utils.TestCounterSyncValueTask(id: 'two', value: 2));
      manager.run(event_utils.TestCounterSyncValueTask(id: 'three', value: 2));
      manager.dispose();
    });
    test('Stream extensions must give events respective to their semantics',
        () async {
      final manager = event_utils.TestCountManager(0);
      const standartSecondsDelay = 2;

      unawaited(
        expectLater(
          manager.on().loading().map((event) => event.task.id),
          emitsInOrder([
            'one',
            'two',
            'throwingError1',
            'throwingError2',
            'killed1',
            'killed2',
            emitsDone
          ]),
        ),
      );

      unawaited(
        expectLater(
          manager.on().success().map((event) => event.task.id),
          emitsInOrder(['one', 'two', emitsDone]),
        ),
      );
      unawaited(
        expectLater(
          manager.on().failed().map((event) => event.task.id),
          emitsInOrder(['throwingError1', 'throwingError2', emitsDone]),
        ),
      );
      unawaited(
        expectLater(
          manager.on().killed().map((event) => event.task.id),
          emitsInOrder(['killed1', 'killed2', emitsDone]),
        ),
      );

      manager.run(
        event_utils.TestCounterAsyncValueTask0(
          id: 'one',
          value: 2,
          delay: const Duration(seconds: standartSecondsDelay),
        ),
      );
      manager.run(
        event_utils.TestCounterAsyncValueTask0(
          id: 'two',
          value: 2,
          delay: const Duration(seconds: standartSecondsDelay),
        ),
      );
      manager.run(
        event_utils.TestCounterAsyncValueTask0(
          id: 'throwingError1',
          throwError: true,
          value: 2,
          delay: const Duration(seconds: standartSecondsDelay),
        ),
      );
      manager.run(
        event_utils.TestCounterAsyncValueTask0(
          id: 'throwingError2',
          throwError: true,
          value: 2,
          delay: const Duration(seconds: standartSecondsDelay),
        ),
      );
      manager.run(
        event_utils.TestCounterAsyncValueTask0(
          id: 'killed1',
          value: 2,
          delay: const Duration(seconds: standartSecondsDelay),
        ),
      );
      manager.run(
        event_utils.TestCounterAsyncValueTask0(
          id: 'killed2',
          value: 2,
          delay: const Duration(seconds: standartSecondsDelay),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));
      await manager.killById(taskId: 'killed1');
      await manager.killById(taskId: 'killed2');
      await Future.delayed(
        const Duration(
          seconds: standartSecondsDelay + 1,
        ),
      );
      manager.dispose();
    });

    test('Stream must give all events if neither the type parameter nor id set',
        () {
      final manager = event_utils.TestCountManager(0);
      expectLater(
        manager
            .on()
            .where((event) => event is TaskSuccessEvent)
            .map((event) => event.task.id),
        emitsInOrder(['one', 'two', 'three', emitsDone]),
      );
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
        emitsInOrder(['one', 'two', emitsDone]),
      );
      manager.run(event_utils.TestCounterSyncValueTask(id: 'one', value: 2));
      manager.run(event_utils.TestCounterSyncValueTask(id: 'two', value: 2));
      manager.run(event_utils.TestCounterSyncValueTask1(id: 'three', value: 2));
      manager.dispose();
    });

    test(
        'Stream must give all events of provided generic type or super type independent of id',
        () {
      final manager = event_utils.TestCountManager(0);
      expectLater(
        manager
            .on<SynchronousTask<int>>()
            .where((event) => event is TaskSuccessEvent)
            .map((event) => event.task.id),
        emitsInOrder(['one', 'two', 'three', emitsDone]),
      );
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
        emitsInOrder(['one', emitsDone]),
      );
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
        emitsInOrder(['two', emitsDone]),
      );
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
        emitsInOrder([emitsDone]),
      );
      manager.run(event_utils.TestCounterSyncValueTask(id: 'one', value: 2));
      manager.run(event_utils.TestCounterSyncValueTask(id: 'two', value: 2));
      manager.run(event_utils.TestCounterSyncValueTask1(id: 'three', value: 2));
      manager.dispose();
    });

    test(
        'Stream will not fire the kill event if a task does not exist or was killed once',
        () async {
      final manager = event_utils.TestCountManager(0);
      unawaited(
        expectLater(
          manager.on().map((event) => event.runtimeType),
          emitsInOrder([TaskLoadingEvent<int>, TaskKillEvent<int>, emitsDone]),
        ),
      );
      const standartSecondsDelay = Duration(seconds: 1);
      manager.run(
        event_utils.TestCounterAsyncValueTask0(
          id: 'killed1',
          value: 2,
          delay: standartSecondsDelay,
        ),
      );
      await manager.killById(taskId: 'killed1');
      await manager.killById(taskId: 'killed1');
      await manager.killById(taskId: 'killed1');
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
        ]),
      );
      expectLater(
        manager
            .on<event_utils.TestCounterSyncValueTask>()
            .map((event) => event.task.id),
        emitsInOrder(['one', 'two', 'three', emitsDone]),
      );
      manager.run(event_utils.TestCounterSyncValueTask(value: 1, id: 'one'));
      manager.run(event_utils.TestCounterSyncValueTask(value: 2, id: 'two'));
      manager.run(event_utils.TestCounterSyncValueTask(value: 3, id: 'three'));
      manager.dispose();
    });
  });
}
