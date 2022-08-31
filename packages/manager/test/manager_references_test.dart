import 'package:test/test.dart';
import 'utils/test_manager_references.dart' as ref_utils;

void main() {
  test('Reference of a task does not exist if task hasn\'t been run', () {
    final manager = ref_utils.TestCountManager(0);
    final task = ref_utils.TestIncrementAsyncTask0();
    expect(manager.testAsyncTaskIdPivotGeneratorRaw(task.id), task.id);
    expect(manager.getAsyncReferenceOf(taskId: task.id), null);
  });
  test(
      'Reference exists unless a task is completed either with success or fail',
      () async {
    final manager = ref_utils.TestCountManager(0);
    final task = ref_utils.TestIncrementAsyncTask0();
    manager.incrementAsync();
    final reference = manager.getAsyncReferenceOf(taskId: task.id);
    expect(reference!.task.id, task.id);
    await manager.waitForTaskToBeDone(taskId: task.id);
    expect(manager.getAsyncReferenceOf(taskId: task.id), null);
    expect(reference.isInternalCompleterCompleted, true);
  });
  test('If a task is replicated, the older reference will be discontinued',
      () async {
    final manager = ref_utils.TestCountManager(0);
    final task = ref_utils.TestIncrementAsyncTask0();
    manager.incrementAsync();
    final reference = manager.getAsyncReferenceOf(taskId: task.id);
    manager.incrementAsync();
    final newReference = manager.getAsyncReferenceOf(taskId: task.id);
    expect(reference!.isInternalCompleterCompleted, true);
    expect(newReference!.isInternalCompleterCompleted, false);
  });
}
