import 'package:flutter/widgets.dart';
import 'package:manager_provider/src/manager_provider.dart';
import 'package:provider/provider.dart';

class MultiManagerProvider extends MultiProvider {
  MultiManagerProvider({
    required List<ManagerProvider> providers,
    required Widget child,
    Key? key,
  }) : super(key: key, providers: providers, child: child);
}
