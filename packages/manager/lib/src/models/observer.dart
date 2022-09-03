import 'package:manager/src/models/manager.dart';
import 'package:manager/src/models/task_event.dart';
import 'package:meta/meta.dart';

abstract class ManagerObserver<T> {
  @internal
  void onCreated(Manager<T> manager) {}

  @internal
  void onDisposed(Manager<T> manager) {}

  @internal
  void onEvent(Manager<T> manager, TaskEvent<T> event) {}

  @internal
  void onStateMutated(T oldState, T newState) {}
}
