import 'package:manager/src/models/manager.dart';
import 'package:manager/src/models/task.dart';
import 'package:manager/src/models/task_event.dart';
import 'package:meta/meta.dart';

typedef StateMutationCallback<T> = void Function(T oldState, T newState);

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
  static void doIfValueIs<T>(dynamic value, void Function() callback) {
    if (value is T) {
      callback();
    }
  }

  @protected
  static void doOnStateMutatedIfValuesAre<T>(
    oldState,
    newState,
    StateMutationCallback<T> onStateMutatedCallBack,
  ) {
    if (oldState is T && newState is T) {
      onStateMutatedCallBack(oldState, newState);
    }
  }

  @protected
  static void doIfManagerIs<M extends Manager>(
    Manager manager,
    void Function() callback,
  ) =>
      doIfValueIs<M>(manager, callback);

  @protected
  static void doIfEventIs<E extends TaskEvent>(
    TaskEvent event,
    void Function() callback,
  ) =>
      doIfValueIs<E>(event, callback);

  @protected
  static void doIfTaskIs<T extends Task<dynamic>>(
    Task task,
    void Function() callback, {
    String? whenTaskId,
  }) {
    if (Manager.tasFlexibleFilter<T, dynamic>(task, whenTaskId)) {
      callback();
    }
  }
}
