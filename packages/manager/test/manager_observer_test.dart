import 'package:manager/src/models/manager.dart';
import 'package:manager/src/models/observer.dart';
import 'package:manager/src/models/task.dart';
import 'package:manager/src/models/task_event.dart';
import 'package:test/test.dart';
import 'utils/test_manager_observer.dart' as test_manager_observer;

class _TestGenericAsyncTask<T> extends AsynchronousTask<T> {
  final Future<T> Function() computation;
  @override
  final String id;

  _TestGenericAsyncTask(this.id, this.computation);

  @override
  Future<T> run() => computation();
}

class _TestCounterManagerTypeCheckObserver extends ManagerObserver {
  @override
  void onCreated(Manager manager) {}

  @override
  void onDisposed(Manager manager) {}

  @override
  void onEvent(Manager manager, TaskEvent event) {
    ManagerObserver.doIfEventIs(event, (_) => _onDoIfEventCalled++);
    ManagerObserver.doIfEventIs<TaskSuccessEvent>(
      event,
      (_) => _onDoIfEventCalled++,
    );
    ManagerObserver.doIfManagerIs<
        test_manager_observer.TestCounterManagerTypeCheck2>(manager, (_) {
      ManagerObserver.doIfEventIs<TaskLoadingEvent>(event, (_) {
        _onDoIfEventCalled++;
      });
    });
    ManagerObserver.doIfEventIs<TaskSuccessEvent>(event, (_) {
      ManagerObserver.doIfTaskIs(event.task, (_) => _onDoTaskIfIsCalled++);
      ManagerObserver.doIfTaskIs(
        event.task,
        (_) => _onDoTaskIfIsCalled++,
        whenTaskId: 'one',
      );
      ManagerObserver.doIfTaskIs<_TestGenericAsyncTask>(
        event.task,
        (_) => _onDoTaskIfIsCalled++,
      );
      ManagerObserver.doIfTaskIs<_TestGenericAsyncTask>(
        event.task,
        (_) => _onDoTaskIfIsCalled++,
        whenTaskId: 'one',
      );
      ManagerObserver.doIfTaskIs<AsynchronousTask<int>>(
        event.task,
        (_) => _onDoTaskIfIsCalled++,
      );
      ManagerObserver.doIfTaskIs<AsynchronousTask>(
        event.task,
        (_) => _onDoTaskIfIsCalled++,
      );
    });
  }

  @override
  void onStateMutated(
    Manager manager,
    oldState,
    newState,
  ) {
    ManagerObserver.doIfManagerIs(manager, (_) {
      _onDoIfManagerCalled++;
    });
    ManagerObserver.doIfManagerIs<
        test_manager_observer.TestCounterManagerTypeCheck1>(manager, (_) {
      _onDoIfManagerCalled++;
    });
    ManagerObserver.doIfManagerIs<
        test_manager_observer.TestCounterManagerTypeCheck2>(manager, (_) {
      _onDoIfManagerCalled++;
    });
  }

  int _onDoIfManagerCalled = 0;
  int _onDoIfEventCalled = 0;
  int _onDoTaskIfIsCalled = 0;
}

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

  group('Testing type check methods of observers - ', () {
    test(
        '.doIfManagerIs invokes the callback on sucessful type check of Manager',
        () {
      final manager1 = test_manager_observer.TestCounterManagerTypeCheck1(0);
      final manager2 = test_manager_observer.TestCounterManagerTypeCheck2('0');
      final observer = _TestCounterManagerTypeCheckObserver();
      manager1.addObserverTest(observer);
      manager2.addObserverTest(observer);
      manager1.run(SynchronousTask.generic(id: 'one', result: 1));
      manager2.run(SynchronousTask.generic(id: 'one', result: '1'));
      expect(observer._onDoIfManagerCalled, 4);
    });
    test(
        '.doIfEventIs invokes the callback on sucessful type check of TaskEvent',
        () async {
      final manager1 = test_manager_observer.TestCounterManagerTypeCheck1(0);
      final manager2 = test_manager_observer.TestCounterManagerTypeCheck2('0');
      final observer = _TestCounterManagerTypeCheckObserver();
      manager1.addObserverTest(observer);
      manager2.addObserverTest(observer);
      manager1.run(SynchronousTask.generic(id: 'one', result: 1));
      manager2.run(
        AsynchronousTask.generic(
          id: 'one',
          computation: () => Future.value('1'),
        ),
      );
      await manager2.waitForTaskToBeDone(taskId: 'one');
      expect(observer._onDoIfEventCalled, 6);
    });
    test('.doIfTaskIs invokes the callback on sucessful type check of Task',
        () async {
      final manager1 = test_manager_observer.TestCounterManagerTypeCheck1(0);
      final manager2 = test_manager_observer.TestCounterManagerTypeCheck2('0');
      final observer = _TestCounterManagerTypeCheckObserver();
      manager1.addObserverTest(observer);
      manager2.addObserverTest(observer);
      manager1.run(_TestGenericAsyncTask<int>('one', () => Future.value(1)));
      manager2
          .run(_TestGenericAsyncTask<String>('two', () => Future.value('1')));
      await manager1.waitForTaskToBeDone(taskId: 'one');
      expect(observer._onDoTaskIfIsCalled, 9);
    });
  });
}
