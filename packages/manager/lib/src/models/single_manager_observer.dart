import 'package:manager/manager.dart';
import 'package:manager/src/models/observer_base.dart';

abstract class SingleManagerObserver<M extends Manager<S>, S>
    extends ManagerObserverBase<M, S> {}
