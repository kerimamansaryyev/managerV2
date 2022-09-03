import 'package:manager/src/models/manager.dart';
import 'package:manager/src/models/observable_manager_mixin.dart';
import 'package:manager/src/models/observer.dart';

class TestObserver0 extends ManagerObserver<int> {
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
  void onCreated(Manager<int> manager) {
    TestCounterManager.onCreatedCalled++;
    super.onCreated(manager);
  }

  @override
  void onDisposed(Manager<int> manager) {
    TestCounterManager.onDisposeCalled++;
    super.onDisposed(manager);
  }

  @override
  void onStateMutated(int oldState, int newState) {
    hasStateMutated = true;
    super.onStateMutated(oldState, newState);
  }
}

class TestObserver1 extends ManagerObserver<int> {
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
  void onCreated(Manager<int> manager) {
    TestCounterManager.onCreatedCalled++;
    super.onCreated(manager);
  }

  @override
  void onDisposed(Manager<int> manager) {
    TestCounterManager.onDisposeCalled++;
    super.onDisposed(manager);
  }

  @override
  void onStateMutated(int oldState, int newState) {
    hasStateMutated = true;
    super.onStateMutated(oldState, newState);
  }
}

class TestCounterManager extends Manager<int> with ObservableManagerMixin<int> {
  static int onCreatedCalled = 0;
  static int onDisposeCalled = 0;

  static void tearDown() {
    onCreatedCalled = 0;
    onDisposeCalled = 0;
  }

  @override
  void mutateState(int newState) {
    if (newState != 2) super.mutateState(newState);
  }

  static final observer0 = TestObserver0();
  static final observer1 = TestObserver1();

  TestCounterManager(super.initialValue);
}
