import 'package:flutter/widgets.dart';
import 'package:manager/manager.dart';
import 'package:provider/provider.dart';

class ManagerProvider<T extends Manager> extends InheritedProvider<T> {
  ManagerProvider({
    required Create<T> create,
    Key? key,
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
    required T value,
    Key? key,
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

  static T of<T extends Manager>(BuildContext context, {bool listen = true}) =>
      Provider.of<T>(context, listen: listen);

  static T? maybeOf<T extends Manager>(
    BuildContext context, {
    bool listen = true,
  }) {
    try {
      return of<T>(context, listen: listen);
    } catch (e) {
      return null;
    }
  }

  static VoidCallback _startListening(
    InheritedContext<Manager?> e,
    Manager value,
  ) {
    final subscription =
        value.onUpdated.listen((_) => e.markNeedsNotifyDependents());
    return subscription.cancel;
  }

  static void _disposeManager<T extends Manager>(
    BuildContext _,
    Manager manager,
  ) =>
      manager.dispose();
}
