import 'package:flutter/widgets.dart';
import 'package:manager/manager.dart';
import 'package:manager_provider/src/manager_selector.dart';

typedef MultiTaskEventListenerUpdatePredicate = bool Function(
  List<TaskEvent?> prev,
  List<TaskEvent?> next,
);

typedef MultiTaskEventListenerWidgetBuilder = Widget Function(
  BuildContext context,
  List<TaskEvent?> events,
  Widget? child,
);

class MultiTaskEventListener<M extends Manager> extends StatelessWidget {
  final MultiTaskEventListenerWidgetBuilder builder;
  final List<String> taskIds;
  final MultiTaskEventListenerUpdatePredicate shouldUpdate;
  final Widget? child;

  const MultiTaskEventListener({
    required this.builder,
    required this.taskIds,
    this.shouldUpdate = _defaultUpdatePredicate,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ManagerSelector<M, List<TaskEvent?>>(
      builder: builder,
      selector: (context, manager) =>
          [for (var id in taskIds) manager.getEventSnapshot(taskId: id)],
      shouldUpdate: shouldUpdate,
      child: child,
    );
  }
}

bool _defaultUpdatePredicate(List<TaskEvent?> _, List<TaskEvent?> __) => true;
