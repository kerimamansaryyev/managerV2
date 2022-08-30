extension StreamUtilExtension on Stream {
  Stream<T> whereTypeFilter<T>() => where((event) => event is T).cast<T>();
}
