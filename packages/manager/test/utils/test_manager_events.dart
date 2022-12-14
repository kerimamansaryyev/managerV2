import 'dart:async';

import 'package:manager/src/models/manager.dart';
import 'package:manager/src/models/task.dart';
import 'package:manager/src/models/task_mixins.dart';

class TestCountManager extends Manager<int> {
  final void Function()? onEventCallbackFunction;

  TestCountManager(super.initialValue, {this.onEventCallbackFunction});

  @override
  void onEventCallback(_) {
    onEventCallbackFunction?.call();
    super.onEventCallback(_);
  }
}

class TestCounterSyncValueTask extends SynchronousTask<int> {
  final int value;
  @override
  final String id;

  const TestCounterSyncValueTask({required this.id, required this.value});

  @override
  int run() {
    return value;
  }
}

class TestCounterAsyncValueTask0 extends AsynchronousTask<int>
    with CancelableAsyncTaskMixin {
  final int value;
  final Duration? delay;
  final bool throwError;

  @override
  final String id;

  const TestCounterAsyncValueTask0({
    required this.id,
    required this.value,
    required this.delay,
    this.throwError = false,
  });

  @override
  Future<int> run() async {
    if (delay != null) {
      await Future.delayed(delay!);
    }
    if (throwError) {
      throw Exception();
    }
    return value;
  }

  @override
  FutureOr<void> kill() async {}
}

class TestCounterAsyncValueTask1 extends AsynchronousTask<int>
    with CancelableAsyncTaskMixin {
  final int value;
  final Duration? delay;
  final bool throwError;
  @override
  final String id;

  const TestCounterAsyncValueTask1({
    required this.id,
    required this.value,
    required this.delay,
    this.throwError = false,
  });

  @override
  Future<int> run() async {
    if (delay != null) {
      await Future.delayed(delay!);
    }

    return value;
  }

  @override
  FutureOr<void> kill() async {}
}

class TestCounterSyncValueTask1 extends SynchronousTask<int> {
  final int value;
  @override
  final String id;

  const TestCounterSyncValueTask1({required this.id, required this.value});

  @override
  int run() {
    return value;
  }
}

class TestCounterAsyncGenericTask extends AsynchronousTask<int>
    with CancelableAsyncTaskMixin {
  final Future<int> Function() runFunction;
  @override
  final String id;

  TestCounterAsyncGenericTask({required this.runFunction, required this.id});

  @override
  Future<int> run() => runFunction();

  @override
  FutureOr<void> kill() async {}
}
