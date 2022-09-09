import 'dart:async';

import 'package:manager/src/models/manager.dart';
import 'package:manager/src/models/task.dart';

/// A special type of [AsynchronousTask] that can be canceled/killed.
///
/// [kill] will be invoked by [Manager.killById] or if a new event is run by a [Manager] while it already
/// has an event with the same reference. (Same [Task.id])
mixin CancelableAsyncTaskMixin<T> on AsynchronousTask<T> {
  FutureOr<void> kill();
}
