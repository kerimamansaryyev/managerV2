import 'package:manager/src/models/manager.dart';
import 'package:manager/src/models/task.dart';
import 'package:manager/src/models/task_event.dart';
import 'package:meta/meta.dart';

typedef StateMutationCastedCallback<T> = void Function(T oldState, T newState);
typedef CastedValueCallback<T> = void Function(T);

/// A class that can observe multiple [Manager]s.
abstract class ManagerObserver {
  @internal
  void onCreated(Manager manager) {}

  @internal
  void onDisposed(Manager manager) {}

  @internal
  void onEvent(Manager manager, TaskEvent event) {}

  @internal
  void onStateMutated(
    Manager manager,
    oldState,
    newState,
  ) {}

  @protected
  static void doIfValueIs<T>(dynamic value, CastedValueCallback<T> callback) {
    if (value is T) {
      callback(value);
    }
  }

  @protected
  static void doOnStateMutatedIfValuesAre<T>(
    oldState,
    newState,
    StateMutationCastedCallback<T> onStateMutatedCallBack,
  ) {
    if (oldState is T && newState is T) {
      onStateMutatedCallBack(oldState, newState);
    }
  }

  @protected
  static void doIfManagerIs<M extends Manager>(
    Manager manager,
    CastedValueCallback<M> callback,
  ) =>
      doIfValueIs<M>(manager, callback);

  @protected
  static void doIfEventIs<E extends TaskEvent>(
    TaskEvent event,
    CastedValueCallback<E> callback,
  ) =>
      doIfValueIs<E>(event, callback);

  @protected
  static void doIfTaskIs<T extends Task<dynamic>>(
    Task task,
    CastedValueCallback<T> callback, {
    String? whenTaskId,
  }) {
    if (Manager.tasFlexibleFilter<T, dynamic>(task, whenTaskId)) {
      callback(task as T);
    }
  }
}
