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
