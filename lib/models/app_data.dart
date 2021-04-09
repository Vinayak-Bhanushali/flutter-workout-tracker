import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workout_tracker/models/enums.dart';

class AppData {
  int noOfRuns;
  UserData userData;
  RemainderSettings remainderSettings;
  AppTheme appTheme;
  AppData({
    @required this.noOfRuns,
    @required this.userData,
    @required this.remainderSettings,
    this.appTheme = AppTheme.System,
  });

  factory AppData.fromRawJson(String str) => AppData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AppData.fromJson(Map<String, dynamic> json) => AppData(
        noOfRuns: json["noOfRuns"] == null ? null : json["noOfRuns"],
        userData: json["userData"] == null
            ? null
            : UserData.fromJson(json["userData"]),
        remainderSettings: json["remainderSettings"] == null
            ? null
            : RemainderSettings.fromJson(json["remainderSettings"]),
        appTheme: json["appTheme"] == null
            ? null
            : appThemeValue.map[json['appTheme']],
      );

  Map<String, dynamic> toJson() => {
        "noOfRuns": noOfRuns == null ? null : noOfRuns,
        "userData": userData == null ? null : userData.toJson(),
        "remainderSettings":
            remainderSettings == null ? null : remainderSettings.toJson(),
        "appTheme": appTheme == null ? null : appThemeValue.reverse[appTheme],
      };
}

class UserData {
  UserData({
    this.name,
    this.age,
    this.height,
    this.weight,
  });

  String name;
  int age;
  double height;
  double weight;

  factory UserData.fromJson(String str) => UserData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserData.fromMap(Map<String, dynamic> json) => UserData(
        name: json["name"] == null ? null : json["name"],
        age: json["age"] == null ? null : json["age"],
        height: json["height"] == null ? null : json["height"].toDouble(),
        weight: json["weight"] == null ? null : json["weight"].toDouble(),
      );

  Map<String, dynamic> toMap() => {
        "name": name == null ? null : name,
        "age": age == null ? null : age,
        "height": height == null ? null : height,
        "weight": weight == null ? null : weight,
      };
}

class RemainderSettings {
  bool enabled;
  Set<int> selectedDays;
  TimeOfDay time;
  DateTime notificationsScheduled;

  RemainderSettings({
    @required this.enabled,
    @required this.selectedDays,
    @required this.time,
    @required this.notificationsScheduled,
  });

  factory RemainderSettings.fromRawJson(String str) =>
      RemainderSettings.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RemainderSettings.fromJson(Map<String, dynamic> json) =>
      RemainderSettings(
        enabled: json["enabled"] == null ? null : json["enabled"],
        selectedDays: json["selectedDays"] == null
            ? null
            : Set<int>.from(json["selectedDays"].map((x) => x)),
        time: json["time"] == null
            ? null
            : TimeOfDay(
                hour: int.parse(json["time"].split(":")[0]),
                minute: int.parse(json["time"].split(":")[1]),
              ),
        notificationsScheduled: json["notificationsScheduled"] == null
            ? null
            : DateTime.parse(json["notificationsScheduled"]),
      );

  Map<String, dynamic> toJson() => {
        "enabled": enabled == null ? null : enabled,
        "selectedDays": selectedDays == null
            ? null
            : List<dynamic>.from(selectedDays.map((x) => x)),
        "time": time == null ? null : "${time.hour}:${time.minute}",
        "notificationsScheduled": notificationsScheduled == null
            ? null
            : notificationsScheduled.toIso8601String(),
      };
}
