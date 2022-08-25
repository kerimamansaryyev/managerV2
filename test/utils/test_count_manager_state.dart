import 'dart:async';

import 'package:manager/src/models/manager.dart';
import 'package:manager/src/models/task.dart';

class TestManagerStateCountManager extends Manager<int> {
  TestManagerStateCountManager(super.initialValue) : super();

  void increment0(
          {Duration delay = const Duration(seconds: 3), int incrementBy = 1}) =>
      run(TestManagerStateAsyncCountIncrementTask0(
          manager: this, incrementBy: incrementBy, delay: delay));

  void increment1(
          {Duration delay = const Duration(seconds: 3), int incrementBy = 1}) =>
      run(TestManagerStateAsyncCountIncrementTask1(
          manager: this, incrementBy: incrementBy, delay: delay));
}

class TestManagerStateAsyncCountIncrementTask0 extends AsynchronousTask<int> {
  final TestManagerStateCountManager manager;
  final int incrementBy;

  final Duration delay;

  const TestManagerStateAsyncCountIncrementTask0(
      {required this.incrementBy, required this.delay, required this.manager});

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

  const TestManagerStateAsyncCountIncrementTask1(
      {required this.incrementBy, required this.delay, required this.manager});

  @override
  Future<int> run() async {
    await Future.delayed(delay);
    return manager.state + incrementBy;
  }
}
