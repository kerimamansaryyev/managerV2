import 'package:manager/manager.dart';

class TestCounterManager extends Manager<int> {
  TestCounterManager(super.initialValue);
}

class TestRecordableCounterManager extends Manager<int>
    with RecordTaskEventsMixin {
  TestRecordableCounterManager(super.initialValue);
}
