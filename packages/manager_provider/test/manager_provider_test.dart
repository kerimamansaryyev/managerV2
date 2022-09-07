import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manager/manager.dart';
import 'package:manager_provider/src/manager_provider.dart';

import 'utils/manager_provider_test_utils.dart' as manager_provider_test_utils;

/// It's okay to ignore the rule on test
// ignore: long-method
void main() {
  testWidgets(
      '.maybeOf will give null after handling assertion error if the provider is not found',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Text(
              ManagerProvider.maybeOf<
                          manager_provider_test_utils
                              .TestCounterManager>(context)
                      ?.state
                      .toString() ??
                  'null',
            );
          },
        ),
      ),
    );
    expect(find.text('null'), findsOneWidget);
  });
  testWidgets(
      'Must find the model of $Manager if a subtree was wrapped by $ManagerProvider',
      (tester) async {
    await tester.pumpWidget(
      ManagerProvider(
        create: (context) => manager_provider_test_utils.TestCounterManager(0),
        builder: (context, __) => MaterialApp(
          home: Text(
            ManagerProvider.of<manager_provider_test_utils.TestCounterManager>(
              context,
            ).state.toString(),
          ),
        ),
      ),
    );
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets(
      'Updates widget if the manager is updated and .of method\'s listen param set to true',
      (tester) async {
    final manager = manager_provider_test_utils.TestCounterManager(0);
    await tester.pumpWidget(
      ManagerProvider.value(
        value: manager,
        builder: (context, __) => MaterialApp(
          home: Text(
            ManagerProvider.of<manager_provider_test_utils.TestCounterManager>(
              context,
            ).state.toString(),
          ),
        ),
      ),
    );
    manager.run(
      SynchronousTask.generic(id: 'increment', result: manager.state + 1),
    );
    manager.run(
      SynchronousTask.generic(id: 'increment', result: manager.state + 1),
    );
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets(
      'A widget will not be updated if the manager is updated and .of method\'s listen param set to false',
      (tester) async {
    final manager = manager_provider_test_utils.TestCounterManager(0);
    await tester.pumpWidget(
      ManagerProvider.value(
        value: manager,
        builder: (context, __) => MaterialApp(
          home: Text(
            ManagerProvider.of<manager_provider_test_utils.TestCounterManager>(
              context,
              listen: false,
            ).state.toString(),
          ),
        ),
      ),
    );
    manager.run(
      SynchronousTask.generic(id: 'increment', result: manager.state + 1),
    );
    manager.run(
      SynchronousTask.generic(id: 'increment', result: manager.state + 1),
    );
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
  });
}
