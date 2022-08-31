import 'package:manager/src/models/manager.dart';
import 'package:manager/src/models/record_tasks_manager_mixin.dart';
import 'package:manager/src/models/task.dart';
import 'package:manager/src/models/task_event.dart';
import 'package:test/test.dart';

class TestRecordableCounterManager extends Manager<int>
    with RecordTaskEventsMixin {
  TestRecordableCounterManager(super.initialValue);
}

void main() {
  test(
      'Must give recorded events as recorded through mixin\'s .onEventCallback',
      () async {
    final manager = TestRecordableCounterManager(0);
    manager.run(AsynchronousTask.generic(
        id: 'one', computation: () => Future.value(2)));
    expect(manager.getRecordedEvent(taskId: 'one').runtimeType,
        TaskLoadingEvent<int>);
    await manager.waitForTaskToBeDone(taskId: 'one');
    expect(manager.getRecordedEvent(taskId: 'one').runtimeType,
        TaskSuccessEvent<int>);
  });
}
