import 'package:test/test.dart';

import 'utils/test_count_manager_state.dart';

void main() {
  test('State is 0 by default', () {
    final manager = TestManagerStateCountManager(0);
    expect(manager.state, 0);
  });
  group(
      'TestManagerStateCountManager\'s state is mutated by asynchronous tasks - ',
      () {
    test('Value is added by 1 after .incremen()', () async {
      final manager = TestManagerStateCountManager(0);
      manager.increment0();

      await manager
          .waitForTaskToBeDone<TestManagerStateAsyncCountIncrementTask0>();

      expect(manager.state, 1);
    });

    test(
        'onStateChanged must emit an event when the state changes by running a successfull task',
        () {
      final manager = TestManagerStateCountManager(0);
      expectLater(manager.onStateChanged, emits(1));
      manager.increment0();
    });

    test(
        'Task replications (with the same type) must be prevented and must not affect on the state even if they are not killed',
        () async {
      final manager = TestManagerStateCountManager(0);
      expectLater(manager.onStateChanged, emitsInOrder([1, 11, emitsDone]));
      manager.increment0();
      manager.increment0();
      manager.increment0();
      await manager
          .waitForTaskToBeDone<TestManagerStateAsyncCountIncrementTask0>();
      manager.increment0(incrementBy: 10);
      await manager
          .waitForTaskToBeDone<TestManagerStateAsyncCountIncrementTask0>();
      expect(manager.state, 11);
      manager.dispose();
    });

    test('Tasks with the same type will be ommited', () async {
      final manager = TestManagerStateCountManager(0);
      manager.increment0();
      manager.increment1(incrementBy: 2, delay: const Duration(seconds: 5));
      manager.increment0();
      await manager
          .waitForTaskToBeDone<TestManagerStateAsyncCountIncrementTask0>();
      await manager
          .waitForTaskToBeDone<TestManagerStateAsyncCountIncrementTask1>();
      manager.increment0(incrementBy: 11);
      await manager
          .waitForTaskToBeDone<TestManagerStateAsyncCountIncrementTask0>();
      expect(manager.state, 14);
    });
  });
}
