# manager

A dart package for predictable synchronous and asynchronous state management with an effective approach. Inspired by `BLoC pattern`, adapted for asynchronous state management.

# Overview

## Task
A structure that represents a mutation operation
applied to `Manager.run`.
`id` is used to distinguish one task from another while being tracked by `Manager`.

There are 2 types of tasks that can be run by the managers:
- `SynchronousTask`. A type of `Task` that changes the state instantly by 
its return value. `Manager` emits only `TaskSuccessEvent` when an instance of this type is run.
- `AsynchronousTask`. A type of `Task` that changes the state if its future completes without an error. `Manager` emits `TaskEvent`s in following order when an instance of this type is run:
    1. `TaskLoadingEvent`
    2. (If it completed without an error) `TaskSuccessEvent` 
       
       (If completed with an error) `TaskErrorEvent`

### CancelableAsyncTaskMixin
It is a special mixin of `AsynchronousTask` that can be killed by `Manager` which triggers `Manager` to emit `TaskKillEvent`.
```dart
manager.killById('id_of_task');
```

## Manager

 An event-driven structure that has the single state of a generic type.

 State changes are encapsulated and only possible to be changed internally by calling
 `mutateState` or by running a `Task` via `run` method.

 Key features and advantages:
 - Every single attempt to change the state has its id and will be tracked.
 - The manager allows running multiple `AsynchronousTasks` concurrently and track progress
 progress of them through `on` method.
 - It is possible to filter and listen to incoming `TaskEvents` through `on` method by
 a type of a `Task` or by `Task.id`. - If you run a `Task` and manager already has a task with the same id - the previous task will be dismissed. So you don't need to worry about unwanted outcomes.
 - An each `Task` that was completed with `TaskSuccessEvent` will change the state through `mutateState`.
 - You can track an every state change by listening to `onStateChanged`
 ```dart
 class CounterManager extends Manager<int> {
  CounterManager(super.initialValue);

  // changes the state instantly
  void incrementSync() =>
      run(SynchronousTask.generic(id: 'increment', result: state + 1));

  // Changes the state after 2 seconds
  void decrementAsync() => run(
        AsynchronousTask.generic(
          id: 'decrement',
          computation: () =>
              Future.delayed(const Duration(seconds: 2), () => state - 1),
        ),
      );
   
   // Will not change the state.
   void decrementAsyncError() => run(
        AsynchronousTask.generic(
          id: 'decrement',
          computation: () async {
            await Future.delayed(const Duration(seconds: 2));
            throw Exception('Exception');
          },
        ),
      );
}
```
### Running tasks
**Note**: Running the same `AsynchronousTask` (with same `id`) when the previous one hasn't been completed will dismiss the previous one and run the new one.
```dart
// Creating a manager
final manager = CounterManager(0);

// Syncronous tasks change manager's state immediately and TaskSuccessEvent is added to the manager
manager.incrementSync();

// prints 1
print(manager.state);

// Running the asynchronous tasks multiple times when the previous ones have not been completed WON'T change the state multiple times but dismiss the previous ones.
manager.decrementAsync();
manager.decrementAsync();
manager.decrementAsync();

await Future.delayed(const Duration(seconds: 2));

// prints 0
print(manager.state);

// If tasks are completed with an error, it will not affect the state
manager.decrementAsyncError();

await Future.delayed(const Duration(seconds: 2));

// prints 0
prints(manager.state);

```
### Listening for events
Manager exposes 2 stream methods:
- `onStateChanged` - emits a value of a manager's updated state.
- `on` - emits an instance of `TaskEvent`.

**It's recommended** to extend the `AsynchronousTask` or `SynchronousTask` rather than using the generic factory constructors of the classes to achieve a better semantics with `on` stream of `Manager`:

```dart
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

class CounterManager extends Manager<int> {
  CounterManager(super.initialValue);

  void incrementSync() => run(SyncIncrementTask(manager: this));

  void decrementAsync() => run(AsynDecrementTask(manager: this));
}

void main(){
  // Listening for events of a specific task by type
  manager.on<SyncIncrementTask>().listen((event){});
  // Listening for events of a specific task by id
  manager.on(taskId: 'increment').listen((event){});
  // Listening for the state changes
  manager.onStateChanged().listen((state){});
}
```

## Observers and observables
Managers that extend `ObservableManagerMixin` can register `ManagerObserver`s.

### ManagerObserver
A structure that can observe multiple managers. Observers can process the following lifecycle events of a manager:
- `onCreated` - When a manager is created.
- `onDisposed` - When a manager is disposed.
- `onEvent` - When an event fired in a manager.
- `onStateMutated` - When the state of a manager has been mutated.

Due to a feature that enables an instance of `ManagerObserver` to observe multiple managers of different types, use the following helper methods to utilize type checks.

- `ManagerObserver.doIfValueIs`
- `ManagerObserver.doOnStateMutatedIfValuesAre`
- `ManagerObserver.doIfManagerIs`
- `ManagerObserver.doIfEventIs`
- `ManagerObserver.doIfTaskIs`

```dart
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
    with ObservableManagerMixin {
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

  manager.run(AsynDecrementTask(manager: manager));
  manager.run(SyncIncrementTask(manager: manager));

  await Future.delayed(const Duration(seconds: 2));
   // prints [TaskLoadingEvent<int>, TaskSuccessEvent<int>, TaskSuccessEvent<int>,]
  print(eventQueueObserver.eventQueue);
  // prints 2
  print(successCountObserver.successEventsCount);

  // removing observers
  manager.removeObserver(eventQueueObserver);
  manager.removeObserver(successCountObserver);
}
```