import 'dart:async';

import 'package:meta/meta.dart';

@immutable
abstract class Task<T> {
  FutureOr<T> run();

  const Task();
}

@immutable
abstract class AsynchronousTask<T> implements Task<T> {
  @override
  Future<T> run();

  const AsynchronousTask();
}

@immutable
abstract class SynchronousTask<T> implements Task<T> {
  @override
  T run();

  const SynchronousTask();
}
