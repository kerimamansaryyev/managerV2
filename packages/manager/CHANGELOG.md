## 0.1.9
Fix: Providing type parameters to `SingleManagerObserver`. 
## 0.1.8
Added `SingleManagerObserver` to observe a specific manager. 
## 0.1.7
Cleared an `example` folder and `README.md` 
## 0.1.6
Updated the `README.md` and the API reference of the package
## 0.1.5
`CastedValueCallback<T>` will be required for the following type check static methods:
  - `ManagerObserver.doIfManagerIs`
  - `ManagerObserver.doIfValueIs`
  - `ManagerObserver.doIfManagerIs`
  - `ManagerObserver.doIfEventIs`
  - `ManagerObserver.doIfTaskIs`
## 0.1.2
`BREAKING CHANGES`:
- In order to make the observers be able to bind to multiple managers, the type parameters of `ManagerObserver` and `ObservableManagerMixin`.
Instead, the following static semantic methods were added to do a type check.
  - `ManagerObserver.doIfManagerIs`
  - `ManagerObserver.doIfValueIs`
  - `ManagerObserver.doOnStateMutatedIfValuesAre`
  - `ManagerObserver.doIfManagerIs`
  - `ManagerObserver.doIfEventIs`
  - `ManagerObserver.doIfTaskIs`
- `ObservableManagerMixin`'s `.addObserver` and `.removeObserver` methods are now public.
## 0.1.0
`BREAKING CHANGES`:
- `ObservableManagerMixin`'s `initialize` was renamed to `initializeObservers`
- `Manager`'s `onStateChanged` getter was reformed to a method accepting `withLatest` optional argument.

`Other changes`:
- `Manager`'s `on` method has now an optional parameter `withLatest` using which will return `BehaviourSubject`'s value stream to get the latest event
emitted when listening to it.
## 0.0.7
Fixed an issue of mixins overriding methods of each other without calling `super`
## 0.0.6
* Added new structures: `ObservableManagerMixin` and `ManagerObserver`
* Added new tests for the structures in `manager_observer_test`
* Regrouped the library structure
## 0.0.5

Added following methods to `RecordTaskEventsMixin`:
* `recordEvent`
* `deleteRecordEvent`
* `eventTable` (exposing it as `protected` member)

Behaviour of instances extending `RecordTaskEventsMixin` was overriden:
Record of the event being killed - will be immediately removed from `_eventTable`
## 0.0.4

Fixed repository link in `pubscpec.yaml`
## 0.0.3

Added `RecordTaskEventsMixin` to enable recording of events. 
## 0.0.2+1

Downgraded `async` dependency to be compatible with flutter
## 0.0.2

- Added `onUpdate` stream to track both events firing and the state changes.
## 0.0.1

- Initial version.
