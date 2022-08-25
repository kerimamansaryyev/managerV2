import 'dart:async';

abstract class Task<T> {
  DateTime? _timeStamp;

  DateTime? get timeStamp => _timeStamp;

  FutureOr<T> run();

  String get id;
}

abstract class AsynchronousTask<T> extends Task<T> {
  @override
  Future<T> run();

  FutureOr<void> kill();

  bool get shouldKBeKilled;
}

abstract class SynchronousTask<T> extends Task<T> {
  @override
  T run();
}
