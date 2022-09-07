import 'package:manager/src/models/task.dart';
import 'package:test/test.dart';
import 'utils/test_manager_observer.dart' as test_manager_observer;

/// It's okay to ignore for test purposes
// ignore: long-method
void main() {
  test('Observable manager initializes observers adding them to the list', () {
    final manager = test_manager_observer.TestCounterManager(0);
    expect(manager.observers.length, 0);
    manager.addObserverTest(test_manager_observer.TestCounterManager.observer0);
    manager.addObserverTest(test_manager_observer.TestCounterManager.observer1);
    manager.initializeTest();
    expect(manager.observers.length, 2);
    expect(
      manager.observers
          .contains(test_manager_observer.TestCounterManager.observer0),
      true,
    );
    expect(
      manager.observers
          .contains(test_manager_observer.TestCounterManager.observer1),
      true,
    );
  });
  test('Observer\'s onCreated method is called in the constructor of Manager',
      () {
    test_manager_observer.TestCounterManager.tearDown();
    final manager = test_manager_observer.TestCounterManager(0);
    manager.addObserverTest(test_manager_observer.TestCounterManager.observer0);
    manager.addObserverTest(test_manager_observer.TestCounterManager.observer1);
    manager.initializeTest();
    expect(test_manager_observer.TestCounterManager.onCreatedCalled, 2);
  });
  test(
      'Observer\'s onDisposed method is called in the dispose method of Manager',
      () {
    test_manager_observer.TestCounterManager.tearDown();
    final manager = test_manager_observer.TestCounterManager(0);
    manager.addObserverTest(test_manager_observer.TestCounterManager.observer0);
    manager.addObserverTest(test_manager_observer.TestCounterManager.observer1);
    manager.initializeTest();
    manager.dispose();
    expect(manager.observers.length, 0);
    expect(test_manager_observer.TestCounterManager.onDisposedCalled, 2);
  });

  test('Observer\'s onEvent method is called whenever Manager receives events',
      () async {
    test_manager_observer.TestCounterManager.tearDown();
    final manager = test_manager_observer.TestCounterManager(0);
    manager.addObserverTest(
      test_manager_observer.TestCounterManager.observer0..tearDown(),
    );
    manager.addObserverTest(
      test_manager_observer.TestCounterManager.observer1..tearDown(),
    );
    manager.initializeTest();
    expect(
      test_manager_observer.TestCounterManager.observer0.eventCount +
          test_manager_observer.TestCounterManager.observer1.eventCount,
      0,
    );
    manager.run(
      AsynchronousTask.generic(
        id: 'one',
        computation: () => Future.delayed(const Duration(seconds: 2), () => 3),
      ),
    );
    await manager.waitForTaskToBeDone(taskId: 'one');
    expect(
      test_manager_observer.TestCounterManager.observer0.eventCount +
          test_manager_observer.TestCounterManager.observer1.eventCount,
      4,
    );
  });

  test(
      'Observer\'s onEvent method is called whenever Manager\'s state is mutated',
      () async {
    test_manager_observer.TestCounterManager.tearDown();
    final manager = test_manager_observer.TestCounterManager(0);
    manager.addObserverTest(
      test_manager_observer.TestCounterManager.observer0..tearDown(),
    );
    manager.addObserverTest(
      test_manager_observer.TestCounterManager.observer1..tearDown(),
    );
    manager.initializeTest();
    manager.run(
      AsynchronousTask.generic(
        id: 'one',
        computation: () => Future.delayed(const Duration(seconds: 2), () => 3),
      ),
    );
    await manager.waitForTaskToBeDone(taskId: 'one');
    expect(
      test_manager_observer.TestCounterManager.observer0.hasStateMutated,
      true,
    );
    expect(
      test_manager_observer.TestCounterManager.observer1.hasStateMutated,
      true,
    );
    test_manager_observer.TestCounterManager.observer0.tearDown();
    test_manager_observer.TestCounterManager.observer1.tearDown();
    manager.run(
      AsynchronousTask.generic(
        id: 'one',
        computation: () => Future.delayed(const Duration(seconds: 2), () => 2),
      ),
    );
    await manager.waitForTaskToBeDone(taskId: 'one');
    expect(
      test_manager_observer.TestCounterManager.observer0.hasStateMutated,
      false,
    );
    expect(
      test_manager_observer.TestCounterManager.observer1.hasStateMutated,
      false,
    );
  });
}
