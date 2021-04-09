// To parse this JSON data, do
//
//     final timeline = timelineFromJson(jsonString);

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:workout_tracker/models/enums.dart';
import 'dart:convert';

import 'package:workout_tracker/models/workout.dart';

class Timeline {
  Timeline({
    this.id,
    @required this.workout,
    @required this.date,
    @required this.imageData,
    @required this.goalsData,
  });

  int id;
  final Workout workout;
  final DateTime date;
  final List<String> imageData;
  final List<GoalData> goalsData;

  factory Timeline.fromRawJson(String str) =>
      Timeline.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Timeline.fromJson(Map<String, dynamic> json) => Timeline(
        id: json["id"] == null ? null : json["id"],
        workout:
            json["workout"] == null ? null : Workout.fromJson(json["workout"]),
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        imageData: json["imageData"] == null
            ? null
            : List<String>.from(json["imageData"].map((x) => x)),
        goalsData: json["goalsData"] == null
            ? null
            : List<GoalData>.from(
                json["goalsData"].map((x) => GoalData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "workout": workout == null ? null : workout.toJson(),
        "date": date == null ? null : date.toIso8601String(),
        "imageData": imageData == null
            ? null
            : List<dynamic>.from(imageData.map((x) => x)),
        "goalsData": goalsData == null
            ? null
            : List<dynamic>.from(goalsData.map((x) => x.toJson())),
      };
}

class GoalData extends Equatable {
  GoalData({
    @required this.exerciseName,
    @required this.setNo,
    @required this.value,
    @required this.unit,
  });

  final String exerciseName;
  final int setNo;
  final int value;
  final Unit unit;

  factory GoalData.fromRawJson(String str) =>
      GoalData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GoalData.fromJson(Map<String, dynamic> json) => GoalData(
        exerciseName:
            json["exerciseName"] == null ? null : json["exerciseName"],
        setNo: json["set"] == null ? null : json["set"],
        value: json["value"] == null ? null : json["value"],
        unit:
            json["unit"] == null ? null : unitFullFormValues.map[json["unit"]],
      );

  Map<String, dynamic> toJson() => {
        "exerciseName": exerciseName == null ? null : exerciseName,
        "set": setNo == null ? null : setNo,
        "value": value == null ? null : value,
        "unit": unit == null ? null : unitFullFormValues.reverse[unit],
      };

  @override
  List<Object> get props => [exerciseName, setNo, value, unit];
}
