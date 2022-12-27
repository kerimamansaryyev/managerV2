import 'package:flutter/widgets.dart';
import 'package:manager/manager.dart';
import 'package:manager_provider/src/manager_selector.dart';

typedef TaskEventListenerUpdatePredicate = bool Function(
  TaskEvent? prev,
  TaskEvent? next,
);

typedef TaskEventListenerWidgetBuilder = Widget Function(
  BuildContext context,
  TaskEvent? event,
  Widget? child,
);

class TaskEventListener<M extends Manager> extends StatelessWidget {
  final M? manager;
  final TaskEventListenerWidgetBuilder builder;
  final String taskId;
  final TaskEventListenerUpdatePredicate shouldUpdate;
  final Widget? child;

  const TaskEventListener({
    required this.builder,
    required this.taskId,
    this.shouldUpdate = _defaultUpdatePredicate,
    this.child,
    this.manager,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ManagerSelector<M, TaskEvent?>(
      manager: manager,
      builder: builder,
      selector: (context, manager) => manager.getEventSnapshot(taskId: taskId),
      shouldUpdate: shouldUpdate,
      child: child,
    );
  }
}

bool _defaultUpdatePredicate(TaskEvent? _, TaskEvent? __) => true;
