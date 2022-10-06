import 'package:manager/src/models/manager.dart';
import 'package:manager/src/models/observer.dart';
import 'package:manager/src/models/observer_base.dart';
import 'package:manager/src/models/task_event.dart';
import 'package:meta/meta.dart';

/// A special interface of [Manager] that can be observed by [ManagerObserver]s
///
/// Adding an observer in constructor and calling [initializeObservers] will trigger [ManagerObserverBase.onCreated]
/// ```dart
/// class CountManager extends Manager<int>{
///   CountManager():super(0){
///      addObserver(MyObserver1());
///      addObserver(MyObserver2());
///      initializeObservers();
///   }
/// }
/// ```
///
/// Adding an observer from outside
/// ```dart
/// final manager = SomeManager();
/// manager.addObserver(MyObserver1());
/// ```
///
/// Removing observers
/// ```dart
/// final manager = SomeManager();
/// manager.removeObserver(MyObserver1());
/// ```
mixin ObservableManagerMixin<T> on Manager<T> {
  final List<ManagerObserverBase> _observers = [];

  @visibleForTesting
  List<ManagerObserverBase> get observers => [..._observers];

  @visibleForTesting
  void addObserverTest(ManagerObserverBase observer) {
    addObserver(observer);
  }

  @visibleForTesting
  void removeObserverTest(ManagerObserverBase observer) {
    removeObserver(observer);
  }

  @visibleForTesting
  void initializeTest() => initializeObservers();

  /// Adds an [observer] to the internal list of observers
  void addObserver(ManagerObserverBase observer) {
    _observers.add(observer);
  }

  /// Removes an observer from the internal list of observers
  void removeObserver(ManagerObserverBase observer) {
    _observers.remove(observer);
  }

  /// Triggers [ManagerObserverBase.onEvent] for all the observers in the internal list
  @mustCallSuper
  @override
  void onEventCallback(TaskEvent<T> event) {
    super.onEventCallback(event);
    for (var observer in _observers) {
      observer.onEvent(this, event);
    }
  }

  /// Triggers [ManagerObserverBase.onCreated] for all the observers in the internal list
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

  /// Triggers [ManagerObserverBase.onCreated] for all the observers in the internal list
  ///
  /// Should be called in the constructor of a class
  @protected
  void initializeObservers() {
    for (var observer in _observers) {
      observer.onCreated(this);
    }
  }

  /// Triggers [ManagerObserverBase.onDisposed] for all the observers in the internal lists
  @mustCallSuper
  @override
  void dispose() {
    for (var observer in _observers) {
      observer.onDisposed(this);
    }
    _observers.clear();
    super.dispose();
  }

  /// Triggers [ManagerObserverBase.onStateMutated] for all the observers in the internal lists
  @mustCallSuper
  @override
  void mutateState(newState) {
    final oldState = state;
    super.mutateState(newState);
    final finalState = state;
    for (var observer in _observers) {
      observer.onStateMutated(this, oldState, finalState);
    }
  }
}
