import 'package:manager/src/models/manager.dart';
import 'package:manager/src/models/task.dart';

class TestCountManager extends Manager<int> {
  TestCountManager(super.initialValue);

  void incrementAsync() => run(TestIncrementAsyncTask0());
}

class TestIncrementAsyncTask0 extends AsynchronousTask<int> {
  @override
  String get id => '0';

  @override
  Future<int> run() => Future.delayed(const Duration(seconds: 3), () => 1);
}
