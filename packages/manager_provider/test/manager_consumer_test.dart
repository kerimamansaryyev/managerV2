import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manager/manager.dart';
import 'package:manager_provider/src/manager_consumer.dart';
import 'package:manager_provider/src/manager_provider.dart';

import 'utils/manager_provider_test_utils.dart' as manager_provider_test_utils;

void main() {
  testWidgets(
      'Consumer gets update whenever the manager\'s onUpdate stream fires an event',
      (tester) async {
    final manager = manager_provider_test_utils.TestCounterManager(0);
    int eventsCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ManagerProvider.value(
          value: manager,
          builder: (context, __) =>
              ManagerConsumer<manager_provider_test_utils.TestCounterManager>(
            builder: (context, manager) => Text(manager.state.toString()),
            onUpdate: () {
              eventsCount++;
            },
          ),
        ),
      ),
    );
    expect(find.text('0'), findsOneWidget);
    // +1 event: Loading
    manager.run(
      AsynchronousTask.generic(
        id: 'one',
        computation: () async {
          await Future.delayed(const Duration(seconds: 2));
          return 2;
        },
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    // +2 events: Success, State is changed
    expect(find.text('2'), findsOneWidget);
    expect(eventsCount, 3);
  });
}
