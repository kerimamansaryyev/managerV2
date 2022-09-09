import 'package:manager/manager.dart';

class AsynDecrementTask extends AsynchronousTask<int> {
  final CounterManager manager;

  AsynDecrementTask({required this.manager});

  @override
  String get id => 'counter_async_task';

  @override
  Future<int> run() async {
    await Future.delayed(const Duration(seconds: 2));
    return manager.state - 1;
  }
}

class SyncIncrementTask extends SynchronousTask<int> {
  final CounterManager manager;

  SyncIncrementTask({required this.manager});

  @override
  String get id => 'counter_sync_task';

  @override
  int run() => manager.state + 1;
}

class SuccesCounterObserver extends ManagerObserver {
  int _internalSuccessCount = 0;

  int get successEventsCount => _internalSuccessCount;

  @override
  void onEvent(Manager manager, TaskEvent event) {
    ManagerObserver.doIfManagerIs<CounterManager>(manager, (_) {
      ManagerObserver.doIfEventIs<TaskSuccessEvent>(event, (_) {
        _internalSuccessCount++;
      });
    });
  }
}

class EventQueueDisplayObserver extends ManagerObserver {
  final eventQueue = <Type>[];

  @override
  void onEvent(Manager manager, TaskEvent event) {
    ManagerObserver.doIfManagerIs<CounterManager>(manager, (_) {
      eventQueue.add(event.runtimeType);
    });
  }
}

class CounterManager extends Manager<int>
    with RecordTaskEventsMixin, ObservableManagerMixin {
  CounterManager(super.initialValue);
}

void main() async {
  // Creating a manager
  final manager = CounterManager(0);

  // Adding the observer to count all success events
  final successCountObserver = SuccesCounterObserver();
  manager.addObserver(successCountObserver);

  // Adding the observer to print a list of orders
  final eventQueueObserver = EventQueueDisplayObserver();
  manager.addObserver(eventQueueObserver);

  // Syncronous tasks change manager's state immediately and TaskSuccessEvent is added to the manager
  manager.run(SyncIncrementTask(manager: manager));
  // adds 1, prints 1
  print(manager.state);
  // prints [TaskEventSuccess<int>]
  print(eventQueueObserver.eventQueue);
  // While Running an AsynchronousTask will
  // If you multiple async tasks with the same id - the previous ones will be dismissed
  manager.run(AsynDecrementTask(manager: manager));
  manager.run(AsynDecrementTask(manager: manager));
  manager.run(AsynDecrementTask(manager: manager));
  // prints [TaskSuccessEvent<int>, TaskLoadingEvent<int>, TaskLoadingEvent<int>, TaskLoadingEvent<int>]
  print(eventQueueObserver.eventQueue);
  await Future.delayed(const Duration(seconds: 2));
  // prints [TaskSuccessEvent<int>, TaskLoadingEvent<int>, TaskLoadingEvent<int>, TaskLoadingEvent<int>, TaskSuccessEvent<int>]
  print(eventQueueObserver.eventQueue);
  // prints 2
  print(successCountObserver.successEventsCount);
}
