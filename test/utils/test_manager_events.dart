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

class TestCounterAsyncValueTask0 extends AsynchronousTask<int> {
  @override
  final String id;
  final int value;
  final Duration? delay;
  final bool throwError;

  @override
  Future<int> run() async {
    if (delay != null) await Future.delayed(delay!);
    return value;
  }

  const TestCounterAsyncValueTask0(
      {required this.id,
      required this.value,
      required this.delay,
      this.throwError = false});
}

class TestCounterAsyncValueTask1 extends AsynchronousTask<int> {
  @override
  final String id;
  final int value;
  final Duration? delay;
  final bool throwError;

  @override
  Future<int> run() async {
    if (delay != null) await Future.delayed(delay!);

    return value;
  }

  const TestCounterAsyncValueTask1(
      {required this.id,
      required this.value,
      required this.delay,
      this.throwError = false});
}

class TestCounterSyncValueTask1 extends SynchronousTask<int> {
  @override
  final String id;
  final int value;

  @override
  int run() {
    return value;
  }

  const TestCounterSyncValueTask1({required this.id, required this.value});
}
