import 'package:manager/src/models/manager.dart';
import 'package:manager/src/models/observable_manager_mixin.dart';
import 'package:manager/src/models/observer.dart';

class TestCounterManagerTypeCheck1 extends Manager<int>
    with ObservableManagerMixin<int> {
  TestCounterManagerTypeCheck1(super.initialValue);
}

class TestCounterManagerTypeCheck2 extends Manager<String>
    with ObservableManagerMixin<String> {
  TestCounterManagerTypeCheck2(super.initialValue);
}

class TestObserver0 extends ManagerObserver {
  int eventCount = 0;
  bool hasStateMutated = false;

  void tearDown() {
    eventCount = 0;
    hasStateMutated = false;
  }

  @override
  void onEvent(manager, event) {
    eventCount++;
  }

  @override
  void onCreated(Manager manager) {
    TestCounterManager._onCreatedCalled++;
    super.onCreated(manager);
  }

  @override
  void onDisposed(Manager manager) {
    TestCounterManager._onDisposeCalled++;
    super.onDisposed(manager);
  }

  @override
  void onStateMutated(Manager manager, oldState, newState) {
    hasStateMutated = true;
    super.onStateMutated(manager, oldState, newState);
  }
}

class TestObserver1 extends ManagerObserver {
  int eventCount = 0;
  bool hasStateMutated = false;

  void tearDown() {
    eventCount = 0;
    hasStateMutated = false;
  }

  @override
  void onEvent(manager, event) {
    eventCount++;
  }

  @override
  void onCreated(Manager manager) {
    TestCounterManager._onCreatedCalled++;
    super.onCreated(manager);
  }

  @override
  void onDisposed(Manager manager) {
    TestCounterManager._onDisposeCalled++;
    super.onDisposed(manager);
  }

  @override
  void onStateMutated(Manager manager, oldState, newState) {
    hasStateMutated = true;
    super.onStateMutated(manager, oldState, newState);
  }
}

class TestCounterManager extends Manager<int> with ObservableManagerMixin<int> {
  static final observer0 = TestObserver0();
  static final observer1 = TestObserver1();

  TestCounterManager(super.initialValue);

  static int get onCreatedCalled => _onCreatedCalled;
  static int get onDisposedCalled => _onDisposeCalled;

  @override
  void mutateState(int newState) {
    if (newState != 2) {
      super.mutateState(newState);
    }
  }

  static int _onCreatedCalled = 0;
  static int _onDisposeCalled = 0;

  static void tearDown() {
    _onCreatedCalled = 0;
    _onDisposeCalled = 0;
  }
}
