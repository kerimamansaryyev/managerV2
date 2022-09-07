import 'dart:async';

import 'package:manager/src/models/task.dart';
import 'package:test/test.dart';

import 'utils/test_count_manager_state.dart';

/// It's okay to ignore the rule for tests
// ignore: long-method
void main() {
  test('onStateChanged() withLatest:true gives the latest emmited value', () {
    final manager = TestManagerStateCountManager(0);
    manager.run(SynchronousTask.generic(id: 'one', result: 1));
    expectLater(
      manager.onStateChanged(),
      emitsInOrder([2, emitsDone]),
    );
    expectLater(
      manager.onStateChanged(withLatest: true),
      emitsInOrder([1, 2, emitsDone]),
    );
    manager.run(SynchronousTask.generic(id: 'two', result: 2));
    manager.dispose();
  });
  test(
      'onStateChanged() withLatest:true gives the initial value on first listen',
      () {
    final manager = TestManagerStateCountManager(0);
    expectLater(manager.onStateChanged(withLatest: true), emits(0));
  });
  test('State is 0 by default', () {
    final manager = TestManagerStateCountManager(0);
    expect(manager.state, 0);
  });

  group('TestManagerStateCountManager\'s state is mutated by synchronous tasks',
      () {
    test(
        'State is mutated in the given order of the tasks synchronously independent of id',
        () {
      final manager = TestManagerStateCountManager(0);
      expectLater(
        manager.onStateChanged(),
        emitsInOrder([1, 2, 4, 7, emitsDone]),
      );
      manager.incrementSync0(id: '0');
      manager.incrementSync0(id: '1');
      manager.incrementSync0(id: '0', incrementBy: 2);
      manager.incrementSync1(id: '0', incrementBy: 3);
      expect(manager.state, 7);
      manager.dispose();
    });
  });

  group(
      'TestManagerStateCountManager\'s state is mutated by asynchronous tasks - ',
      () {
    test('Value is added by 1 after .increment()', () async {
      final manager = TestManagerStateCountManager(0);
      manager.increment0(id: '0');

      await manager.waitForTaskToBeDone(taskId: '0');

      expect(manager.state, 1);
    });

    test(
        'onStateChanged must emit an event when the state changes by running a successfull task',
        () {
      final manager = TestManagerStateCountManager(0);
      expectLater(manager.onStateChanged(), emits(1));
      manager.increment0(id: '0');
    });

    test(
        'Task replications (with the same id) must be prevented and must not affect on the state even if they are not killed',
        () async {
      final manager = TestManagerStateCountManager(0);
      unawaited(
        expectLater(
          manager.onStateChanged(),
          emitsInOrder([1, 11, emitsDone]),
        ),
      );
      manager.increment0(id: '0');
      manager.increment0(id: '0');
      manager.increment0(id: '0');
      await manager.waitForTaskToBeDone(taskId: '0');
      manager.increment0(incrementBy: 10, id: '0');
      await manager.waitForTaskToBeDone(taskId: '0');
      expect(manager.state, 11);
      manager.dispose();
    });

    test('Tasks with the same id will be ommited, even if types are different.',
        () async {
      final manager = TestManagerStateCountManager(0);
      manager.increment0(id: '0');
      manager.increment1(
        incrementBy: 2,
        delay: const Duration(seconds: 5),
        id: '0',
      );
      manager.increment0(id: '2');
      await manager.waitForTaskToBeDone(taskId: '0');
      manager.increment0(incrementBy: 11, id: '0');
      await manager.waitForTaskToBeDone(taskId: '0');
      expect(manager.state, 14);
    });

    test('Tasks that complete with an error will not mutate state', () async {
      final manager = TestManagerStateCountManager(0);
      manager.increment0(id: '0');
      manager.increment1(
        incrementBy: 2,
        delay: const Duration(seconds: 5),
        id: '0',
      );
      manager.increment0(id: '2');
      manager.run(TestManagerStateAsyncCounterErrorTask(id: '0'));
      await manager.waitForTaskToBeDone(taskId: '0');
      manager.increment0(incrementBy: 11, id: '0');
      await manager.waitForTaskToBeDone(taskId: '0');
      expect(manager.state, 12);
    });
  });

  test(
      'When mutateState is overriden - success tasks will still fire but the state may not be changed',
      () {
    final manager =
        TestCounterConditionedManager(0, (newState) => newState > 1);
    expectLater(manager.onStateChanged(), emitsInOrder([2, 3, emitsDone]));
    manager.run(SynchronousTask.generic(id: 'one', result: 1));
    expect(manager.state, 0);
    manager.run(SynchronousTask.generic(id: 'one', result: 2));
    manager.run(SynchronousTask.generic(id: 'one', result: 3));
    manager.run(SynchronousTask.generic(id: 'one', result: 1));
    expect(manager.state, 3);
    manager.dispose();
  });
}
