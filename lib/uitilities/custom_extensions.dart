extension CustomString on String {
  String addFourSpace() {
    return "${this}    ";
  }

  String isMultiple(int count) {
    if (count > 1)
      return "${this}s";
    else
      return this;
  }
}

Iterable<MapEntry<int, T>> enumerate<T>(Iterable<T> items) sync* {
  int index = 0;
  for (T item in items) {
    yield MapEntry(index, item);
    index = index + 1;
  }
}
