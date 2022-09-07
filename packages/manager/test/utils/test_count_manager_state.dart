import 'dart:async';

import 'package:manager/src/models/manager.dart';
import 'package:manager/src/models/task.dart';

class TestCounterConditionedManager extends Manager<int> {
  final bool Function(int newState) mutateDecisionPredicate;

  TestCounterConditionedManager(
    super.initialValue,
    this.mutateDecisionPredicate,
  );

  @override
  void mutateState(int newState) {
    if (mutateDecisionPredicate(newState)) {
      super.mutateState(newState);
    }
  }
}

class TestManagerStateCountManager extends Manager<int> {
  TestManagerStateCountManager(super.initialValue) : super();

  void increment0({
    required String id,
    Duration delay = const Duration(seconds: 3),
    int incrementBy = 1,
  }) =>
      run(
        TestManagerStateAsyncCountIncrementTask0(
          manager: this,
          incrementBy: incrementBy,
          delay: delay,
          id: id,
        ),
      );

  void increment1({
    required String id,
    Duration delay = const Duration(seconds: 3),
    int incrementBy = 1,
  }) =>
      run(
        TestManagerStateAsyncCountIncrementTask1(
          manager: this,
          incrementBy: incrementBy,
          delay: delay,
          id: id,
        ),
      );

  void incrementSync0({required String id, int incrementBy = 1}) => run(
        TestManagerStateSyncIncrementTask0(
          manager: this,
          incrementBy: incrementBy,
          id: id,
        ),
      );

  void incrementSync1({
    required String id,
    int incrementBy = 1,
  }) =>
      run(
        TestManagerStateSyncIncrementTask1(
          manager: this,
          incrementBy: incrementBy,
          id: id,
        ),
      );
}

class TestManagerStateAsyncCounterErrorTask extends AsynchronousTask<int> {
  @override
  final String id;

  TestManagerStateAsyncCounterErrorTask({required this.id});

  @override
  Future<int> run() async {
    await Future.delayed(const Duration(seconds: 2));
    throw Exception('Exception test');
  }
}

class TestManagerStateAsyncCountIncrementTask0 extends AsynchronousTask<int> {
  final TestManagerStateCountManager manager;
  final int incrementBy;
  final Duration delay;

  @override
  final String id;

  const TestManagerStateAsyncCountIncrementTask0({
    required this.incrementBy,
    required this.delay,
    required this.manager,
    required this.id,
  });

  @override
  Future<int> run() async {
    await Future.delayed(delay);
    return manager.state + incrementBy;
  }
}

class TestManagerStateAsyncCountIncrementTask1 extends AsynchronousTask<int> {
  final TestManagerStateCountManager manager;
  final int incrementBy;
  final Duration delay;

  @override
  final String id;

  const TestManagerStateAsyncCountIncrementTask1({
    required this.incrementBy,
    required this.delay,
    required this.manager,
    required this.id,
  });

  @override
  Future<int> run() async {
    await Future.delayed(delay);
    return manager.state + incrementBy;
  }
}

class TestManagerStateSyncIncrementTask0 extends SynchronousTask<int> {
  final TestManagerStateCountManager manager;
  final int incrementBy;
  @override
  final String id;

  TestManagerStateSyncIncrementTask0({
    required this.id,
    required this.manager,
    this.incrementBy = 1,
  });

  @override
  int run() {
    return manager.state + incrementBy;
  }
}

class TestManagerStateSyncIncrementTask1 extends SynchronousTask<int> {
  final TestManagerStateCountManager manager;
  final int incrementBy;
  @override
  final String id;

  TestManagerStateSyncIncrementTask1({
    required this.id,
    required this.manager,
    this.incrementBy = 1,
  });

  @override
  int run() {
    return manager.state + incrementBy;
  }
}
