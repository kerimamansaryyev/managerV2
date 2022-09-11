import 'package:manager/src/models/manager.dart';
import 'package:manager/src/models/observer.dart';
import 'package:manager/src/models/single_manager_observer.dart';
import 'package:manager/src/models/task_event.dart';
import 'package:meta/meta.dart';

/// An abstract interface implemented by [ManagerObserver] and [SingleManagerObserver]
abstract class ManagerObserverBase<M extends Manager<S>, S> {
  @internal
  void onCreated(M manager) {}

  @internal
  void onDisposed(M manager) {}

  @internal
  void onEvent(M manager, TaskEvent<S> event) {}

  @internal
  void onStateMutated(
    M manager,
    S oldState,
    S newState,
  ) {}
}
