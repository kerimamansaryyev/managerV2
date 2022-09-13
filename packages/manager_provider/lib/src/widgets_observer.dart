import 'package:flutter/widgets.dart';
import 'package:manager/manager.dart';

mixin ManagerWidgetsObserverMixin<T extends StatefulWidget> on State<T>
    implements ManagerObserver {
  @override
  void onCreated(Manager manager) {}

  @override
  void onDisposed(Manager manager) {}

  @override
  void onEvent(Manager manager, TaskEvent event) {}

  @override
  void onStateMutated(Manager manager, oldState, newState) {}
}

mixin SingleManagerWidgetsObserverMixin<
    T extends StatefulWidget,
    M extends Manager<S>,
    S> on State<T> implements SingleManagerObserver<M, S> {
  @override
  void onCreated(M manager) {}

  @override
  void onDisposed(M manager) {}

  @override
  void onEvent(M manager, TaskEvent<S> event) {}

  @override
  void onStateMutated(M manager, S oldState, S newState) {}
}
