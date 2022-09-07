import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manager/manager.dart';
import 'package:manager_provider/src/manager_provider.dart';
import 'package:manager_provider/src/manager_selector.dart';

import 'utils/manager_provider_test_utils.dart' as manager_provider_test_utils;

/// It's okay to ignore the rule on test
// ignore: long-method
void main() {
  testWidgets('The child won\'t be updated if shouldUpdate() didn\'t give true',
      (tester) async {
    final manager = manager_provider_test_utils.TestCounterManager(0);
    await tester.pumpWidget(
      MaterialApp(
        home: ManagerProvider.value(
          value: manager_provider_test_utils.TestCounterManager(0),
          builder: (context, _) => ManagerSelector<
              manager_provider_test_utils.TestCounterManager, int>(
            builder: (context, value, child) => Text(value.toString()),
            selector: (context, manager) => manager.state,
            shouldUpdate: (prev, next) => false,
          ),
        ),
      ),
    );
    manager.run(const SynchronousTask.generic(id: 'one', result: 2));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
  });
  testWidgets('The child won\'t be updated if shouldUpdate() gives true',
      (tester) async {
    final manager = manager_provider_test_utils.TestCounterManager(0);
    await tester.pumpWidget(
      MaterialApp(
        home: ManagerProvider.value(
          value: manager,
          builder: (context, _) => ManagerSelector<
              manager_provider_test_utils.TestCounterManager, int>(
            builder: (context, value, child) => Text(value.toString()),
            selector: (context, manager) => manager.state,
            shouldUpdate: (prev, next) => prev != next,
          ),
        ),
      ),
    );
    manager.run(const SynchronousTask.generic(id: 'one', result: 2));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets(
      'Status text must be changed if respective async task added to the queue',
      (tester) async {
    final manager = manager_provider_test_utils.TestRecordableCounterManager(0);
    await tester.pumpWidget(
      MaterialApp(
        home: ManagerProvider.value(
          value: manager,
          builder: (context, _) => ManagerSelector<
              manager_provider_test_utils.TestRecordableCounterManager,
              TaskEvent<int>?>(
            builder: (context, value, child) {
              return Text(value?.runtimeType.toString() ?? 'null');
            },
            selector: (context, manager) =>
                manager.getRecordedEvent(taskId: 'one'),
            shouldUpdate: (prev, next) => prev != next,
          ),
        ),
      ),
    );
    expect(find.text('null'), findsOneWidget);
    manager.run(
      AsynchronousTask.generic(
        id: 'one',
        computation: () async {
          await Future.delayed(const Duration(seconds: 2));
          return 2;
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('TaskLoadingEvent<int>'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('TaskSuccessEvent<int>'), findsOneWidget);
  });
}
