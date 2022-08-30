import 'dart:async';

import 'package:manager/src/models/task.dart';

mixin CancelableAsyncTaskMixin<T> on AsynchronousTask<T> {
  FutureOr<void> kill();
}
