import 'package:flutter/widgets.dart';
import 'package:manager/manager.dart';
import 'package:manager_provider/src/utils/selector_interfaces.dart';

void _emptyCallback() {}

class ManagerSelector<M extends Manager, V> extends StatefulWidget
    with ManagerSelectorWidgetInterfaceMixin<M, V> {
  @override
  final M? manager;

  @override
  final ManagerSelectorBuilder<V> builder;

  @override
  final Widget? child;

  @override
  final ManagerSelectorUpdateCallback onUpdate;

  @override
  final ManagerSelectorExtractor<M, V> selector;

  @override
  final ManagerSelectedDecisionPredicate<V> shouldUpdate;

  const ManagerSelector({
    required this.builder,
    required this.selector,
    required this.shouldUpdate,
    Key? key,
    this.child,
    this.onUpdate = _emptyCallback,
    this.manager,
  }) : super(key: key);

  @override
  State<ManagerSelector> createState() => _ManagerSelectorState<M, V>();
}

class _ManagerSelectorState<M extends Manager, V>
    extends State<ManagerSelector<M, V>>
    with ManagerSelectorStateMixin<ManagerSelector<M, V>, M, V> {
  @override
  void initState() {
    initSubscription();
    super.initState();
  }

  @override
  void dispose() {
    cancelSubscription();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => childBuilder(context);
}
