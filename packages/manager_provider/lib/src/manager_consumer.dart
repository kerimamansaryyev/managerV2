import 'package:flutter/widgets.dart';
import 'package:manager/manager.dart';
import 'package:manager_provider/src/manager_selector.dart';

typedef ManagerConsumerBuilder<T extends Manager> = Widget Function(
  BuildContext context,
  T manager,
);
typedef ManagerConsumerUpdateCallback = void Function();

void _emptyCallback() {}

class ManagerConsumer<T extends Manager> extends StatelessWidget {
  final T? manager;
  final ManagerConsumerBuilder<T> builder;
  final ManagerConsumerUpdateCallback onUpdate;

  const ManagerConsumer({
    required this.builder,
    Key? key,
    this.onUpdate = _emptyCallback,
    this.manager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ManagerSelector<T, T>(
        manager: manager,
        builder: (context, manager, __) => builder(context, manager),
        selector: (context, manager) => manager,
        onUpdate: onUpdate,
        shouldUpdate: (_, __) => true,
      );
}
