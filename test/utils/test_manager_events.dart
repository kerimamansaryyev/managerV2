import 'package:manager/src/models/manager.dart';
import 'package:manager/src/models/task.dart';

class TestCountManager extends Manager<int> {
  TestCountManager(super.initialValue);
}

class TestCounterConditionedManager extends Manager<int> {
  TestCounterConditionedManager(
      super.initialValue, this.mutateDecisionPredicate);

  final bool Function(int newState) mutateDecisionPredicate;

  @override
  void mutateState(int newState) {
    if (mutateDecisionPredicate(newState)) {
      super.mutateState(newState);
    }
  }
}

class TestCounterSyncValueTask extends SynchronousTask<int> {
  @override
  final String id;
  final int value;

  @override
  int run() {
    return value;
  }

  const TestCounterSyncValueTask({required this.id, required this.value});
}
