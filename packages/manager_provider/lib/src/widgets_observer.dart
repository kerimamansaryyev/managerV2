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
