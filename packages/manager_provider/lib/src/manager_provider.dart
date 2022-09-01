import 'package:flutter/widgets.dart';
import 'package:manager/manager.dart';
import 'package:provider/provider.dart';

class ManagerProvider<T extends Manager> extends InheritedProvider<T> {
  ManagerProvider({
    Key? key,
    required Create<T> create,
    bool? lazy,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(
          key: key,
          startListening: _startListening,
          create: create,
          dispose: _disposeManager<T>,
          lazy: lazy,
          builder: builder,
          child: child,
        );

  ManagerProvider.value({
    Key? key,
    required T value,
    UpdateShouldNotify<T>? updateShouldNotify,
    TransitionBuilder? builder,
    Widget? child,
  }) : super.value(
          key: key,
          builder: builder,
          value: value,
          updateShouldNotify: updateShouldNotify,
          startListening: _startListening,
          child: child,
        );

  static VoidCallback _startListening(
    InheritedContext<Manager?> e,
    Manager value,
  ) {
    final subscription =
        value.onUpdated.listen((_) => e.markNeedsNotifyDependents());
    return subscription.cancel;
  }

  static void _disposeManager<T extends Manager>(
          BuildContext _, Manager manager) =>
      manager.dispose();

  static T of<T extends Manager>(BuildContext context, {bool listen = true}) =>
      Provider.of<T>(context, listen: listen);

  static T? maybeOf<T extends Manager>(BuildContext context,
      {bool listen = true}) {
    try {
      return of<T>(context, listen: listen);
    } catch (e) {
      return null;
    }
  }
}
