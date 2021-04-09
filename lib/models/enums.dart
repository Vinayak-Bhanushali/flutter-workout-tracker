class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}

enum Unit {
  SECS,
  REPS,
}

// final unitValues = EnumValues({
//   "Rep": Unit.REPS,
//   "Sec": Unit.SECS,
// });
final unitFullFormValues = EnumValues({
  "Repitition": Unit.REPS,
  "Second": Unit.SECS,
});

enum AppTheme {
  Light,
  Dark,
  System,
}

final appThemeValue = EnumValues({
  "Light": AppTheme.Light,
  "Dark": AppTheme.Dark,
  "System": AppTheme.System,
});
