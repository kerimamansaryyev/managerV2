import 'dart:async';

import 'package:manager/src/models/task.dart';
import 'package:meta/meta.dart';

class AsyncTaskCompleteReferenceCyclestamp {
  int? _cycle;

  int? get cycle => _cycle;

  void checkout() {
    if (_cycle == null) {
      _cycle = 0;
      return;
    }

    _cycle = _cycle! + 1;
  }
}

@immutable
class AsyncTaskCompleterReference<T> {
  final AsynchronousTask<T> task;
  final Completer<T> completer;
  final AsyncTaskCompleteReferenceCyclestamp cyclestampSnapshot;

  bool isOutDatedComparingTo(AsyncTaskCompleterReference other) {
    if (other.cyclestampSnapshot.cycle == null) return false;
    if (cyclestampSnapshot.cycle == null) return true;

    return other.cyclestampSnapshot.cycle! > cyclestampSnapshot.cycle!;
  }

  const AsyncTaskCompleterReference._(
      {required this.completer,
      required this.task,
      required this.cyclestampSnapshot});

  AsyncTaskCompleterReference.create(AsynchronousTask<T> task)
      : this._(
            task: task,
            completer: Completer(),
            cyclestampSnapshot: AsyncTaskCompleteReferenceCyclestamp());
}
