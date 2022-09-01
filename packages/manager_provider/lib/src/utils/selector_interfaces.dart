import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:manager/manager.dart';
import 'package:manager_provider/src/manager_provider.dart';

typedef ManagerSelectorExtractor<M extends Manager, V> = V Function(
    BuildContext context, M manager);
typedef ManagerSelectedDecisionPredicate<V> = bool Function(V prev, V next);
typedef ManagerSelectorUpdateCallback = void Function();
typedef ManagerSelectorBuilder<V> = Widget Function(
    BuildContext context, V value, Widget? child);

mixin ManagerSelectorWidgetInterfaceMixin<M extends Manager, V>
    on StatefulWidget {
  ManagerSelectorExtractor<M, V> get selector;
  ManagerSelectedDecisionPredicate<V> get shouldUpdate;
  ManagerSelectorUpdateCallback get onUpdate;
  ManagerSelectorBuilder<V> get builder;
  Widget? get child;
}

mixin ManagerSelectorStateMixin<
    W extends ManagerSelectorWidgetInterfaceMixin<M, V>,
    M extends Manager,
    V> on State<W> {
  StreamSubscription? _subscription;
  late V _currentValue;

  void _onManagerUpdated() {
    final potentialNewValue = widget.selector(context, _getManager());
    if (widget.shouldUpdate(_currentValue, potentialNewValue)) {
      _currentValue = potentialNewValue;
      widget.onUpdate();
      setState(() {});
    } else {
      _currentValue = potentialNewValue;
    }
  }

  M _getManager() => ManagerProvider.of<M>(context, listen: false);

  @mustCallSuper
  @protected
  void initSubscription() {
    final manager = _getManager();
    _currentValue = widget.selector(context, manager);
    _subscription = manager.onUpdated.listen((_) => _onManagerUpdated());
  }

  @mustCallSuper
  @protected
  void cancelSubscription() {
    _subscription?.cancel();
  }

  Widget childBuilder(BuildContext context) =>
      widget.builder(context, _currentValue, widget.child);
}
