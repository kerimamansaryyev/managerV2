## 0.4.3
Added an option to provide custom `Manager` instance to the widgets that use `ManagerSelector`.
## 0.4.2
Synced with `manager:0.4.1`.
## 0.4.1+1
Added the new widgets from `0.4.1` to the exports.
## 0.4.1
- Synced with `manager:0.4.0+1`.
- Added new widgets: `MultiTaskEventListener`, `TaskEventListener`.
## 0.3.3
Calling `onEventCallback` before passing the event to the stream controllers in `_passEvent` method.
## 0.3.2
Reverting `0.3.1`.

Fixed an issue of successfull task events returning `TaskProgressStatus.error`.
## 0.3.1
Exposing `progressStatus` getter of `TaskEvent`.
## 0.3.0
Fixed an issue when the observers' `onStateMutated` exposed only the new state.
## 0.2.1
Upgraded dependencies.
## 0.2.0
Added `SingleManagerWidgetsObserverMixin`.
## 0.1.9
Exporting `MultiManagerProvider`.
## 0.1.8
Added `MultiManagerProvider`.
## 0.1.7
Syncing with `manager:0.1.7`.
## 0.1.6

Added `ManagerWidgetsObserverMixin` to make managers observable from widget states
## 0.1.5

Synced with `manager:0.1.5` requiring `CastedValueCallback<T>` for the static type check methods of `ManagerObserver`
## 0.1.2

Migrated to the new version of `manager` keeping up-to-date with the breaking changes.
## 0.0.7

Syncing with the new structures of `manager`:
Fixed an issue of mixins overriding the methods of the class without calling
`super`
## 0.0.6

Syncing with the new structures of `manager`
## 0.0.5

Exposing the latest version of `manager`
## 0.0.4

* Updated `manager` dependency
* Fixed the repository link
## 0.0.3

* Configured the exports
## 0.0.2

* Added the `repository` to `pubspec.yaml`
## 0.0.1

* Initial release with `ManagerProvider`, `ManagerConsumer` and `ManagerSelector`
