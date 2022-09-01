import 'package:flutter/widgets.dart';
import 'package:manager/manager.dart';
import 'package:manager_provider/src/manager_selector.dart';

typedef ManagerConsumerBuilder<T extends Manager> = Widget Function(
    BuildContext context, T manager);
typedef ManagerConsumerUpdateCallback = void Function();

void _emptyCallback() {}

class ManagerConsumer<T extends Manager> extends StatelessWidget {
  const ManagerConsumer(
      {Key? key, required this.builder, this.onUpdate = _emptyCallback})
      : super(key: key);

  final ManagerConsumerBuilder<T> builder;
  final ManagerConsumerUpdateCallback onUpdate;

  @override
  Widget build(BuildContext context) => ManagerSelector<T, T>(
      builder: (context, manager, __) => builder(context, manager),
      selector: (context, manager) => manager,
      onUpdate: onUpdate,
      shouldUpdate: (_, __) => true);
}
