import 'dart:async';

import 'package:manager/src/models/manager.dart';
import 'package:manager/src/models/task.dart';

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

class TestManagerStateCountManager extends Manager<int> {
  TestManagerStateCountManager(super.initialValue) : super();

  void increment0(
          {Duration delay = const Duration(seconds: 3),
          int incrementBy = 1,
          required String id}) =>
      run(TestManagerStateAsyncCountIncrementTask0(
          manager: this, incrementBy: incrementBy, delay: delay, id: id));

  void increment1(
          {Duration delay = const Duration(seconds: 3),
          int incrementBy = 1,
          required String id}) =>
      run(TestManagerStateAsyncCountIncrementTask1(
          manager: this, incrementBy: incrementBy, delay: delay, id: id));

  void incrementSync0({int incrementBy = 1, required String id}) =>
      run(TestManagerStateSyncIncrementTask0(
          manager: this, incrementBy: incrementBy, id: id));

  void incrementSync1({int incrementBy = 1, required String id}) =>
      run(TestManagerStateSyncIncrementTask1(
          manager: this, incrementBy: incrementBy, id: id));
}

class TestManagerStateAsyncCounterErrorTask extends AsynchronousTask<int> {
  TestManagerStateAsyncCounterErrorTask({required this.id});

  @override
  final String id;

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

  const TestManagerStateAsyncCountIncrementTask0(
      {required this.incrementBy,
      required this.delay,
      required this.manager,
      required this.id});

  @override
  Future<int> run() async {
    await Future.delayed(delay);
    return manager.state + incrementBy;
  }

  @override
  final String id;
}

class TestManagerStateAsyncCountIncrementTask1 extends AsynchronousTask<int> {
  final TestManagerStateCountManager manager;
  final int incrementBy;

  final Duration delay;

  const TestManagerStateAsyncCountIncrementTask1(
      {required this.incrementBy,
      required this.delay,
      required this.manager,
      required this.id});

  @override
  Future<int> run() async {
    await Future.delayed(delay);
    return manager.state + incrementBy;
  }

  @override
  final String id;
}

class TestManagerStateSyncIncrementTask0 extends SynchronousTask<int> {
  final TestManagerStateCountManager manager;
  final int incrementBy;
  @override
  final String id;

  TestManagerStateSyncIncrementTask0(
      {required this.manager, this.incrementBy = 1, required this.id});

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

  TestManagerStateSyncIncrementTask1(
      {required this.manager, this.incrementBy = 1, required this.id});

  @override
  int run() {
    return manager.state + incrementBy;
  }
}
