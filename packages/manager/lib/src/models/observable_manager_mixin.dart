import 'package:manager/src/models/manager.dart';
import 'package:manager/src/models/observer.dart';
import 'package:manager/src/models/task_event.dart';
import 'package:meta/meta.dart';

mixin ObservableManagerMixin<T> on Manager<T> {
  final List<ManagerObserver> _observers = [];

  @visibleForTesting
  List<ManagerObserver> get observers => [..._observers];

  @visibleForTesting
  void addObserverTest(ManagerObserver observer) {
    addObserver(observer);
  }

  @visibleForTesting
  void removeObserverTest(ManagerObserver observer) {
    removeObserver(observer);
  }

  @visibleForTesting
  void initializeTest() => initializeObservers();

  void addObserver(ManagerObserver observer) {
    _observers.add(observer);
  }

  void removeObserver(ManagerObserver observer) {
    _observers.remove(observer);
  }

  @mustCallSuper
  @override
  void onEventCallback(TaskEvent<T> event) {
    for (var observer in _observers) {
      observer.onEvent(this, event);
    }
    super.onEventCallback(event);
  }

  @Deprecated(
    'The method was renamed to initializeObservers and will be removed in major releases',
  )
  @mustCallSuper
  @protected
  void initialize() {
    for (var observer in _observers) {
      observer.onCreated(this);
    }
  }

  @protected
  void initializeObservers() {
    for (var observer in _observers) {
      observer.onCreated(this);
    }
  }

  @mustCallSuper
  @override
  void dispose() {
    for (var observer in _observers) {
      observer.onDisposed(this);
    }
    _observers.clear();
    super.dispose();
  }

  @mustCallSuper
  @override
  void mutateState(newState) {
    final potentialState = newState;
    super.mutateState(newState);
    final finalState = state;
    for (var observer in _observers) {
      observer.onStateMutated(this, potentialState, finalState);
    }
  }
}
