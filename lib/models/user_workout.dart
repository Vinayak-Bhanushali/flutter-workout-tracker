// To parse this JSON data, do
import 'package:meta/meta.dart';
import 'dart:convert';

import 'package:workout_tracker/models/workout.dart';

class UserWorkout {
  UserWorkout({
    this.startTime,
    @required this.exerciseData,
    this.id,
    this.workout,
    this.endTime,
  });

  int id;
  Workout workout;
  List<ExerciseDatum> exerciseData;
  DateTime startTime;
  DateTime endTime;

  factory UserWorkout.fromRawJson(String str) =>
      UserWorkout.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserWorkout.fromJson(Map<String, dynamic> json) => UserWorkout(
        id: json["id"] == null ? null : json["id"],
        exerciseData: json["exerciseData"] == null
            ? null
            : List<ExerciseDatum>.from(
                json["exerciseData"].map((x) => ExerciseDatum.fromJson(x))),
        workout:
            json["workout"] == null ? null : Workout.fromJson(json["workout"]),
        startTime: json["startTime"] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(json["startTime"]),
        endTime: json["endTime"] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(json["endTime"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "exerciseData": exerciseData == null
            ? null
            : List<dynamic>.from(exerciseData.map((x) => x.toJson())),
        "workout": workout == null ? null : workout.toJson(),
        "startTime": startTime == null
            ? null
            : startTime
                .millisecondsSinceEpoch, //Converting to milliseconds cause sembast does not allows on querying datetime
        "endTime": endTime == null ? null : endTime.millisecondsSinceEpoch,
      };
}

class ExerciseDatum {
  ExerciseDatum({
    @required this.exerciseId,
    @required this.setData,
  });

  int exerciseId;
  List<int> setData;

  factory ExerciseDatum.fromRawJson(String str) =>
      ExerciseDatum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ExerciseDatum.fromJson(Map<String, dynamic> json) => ExerciseDatum(
        exerciseId: json["exerciseId"] == null ? null : json["exerciseId"],
        setData: json["setData"] == null
            ? null
            : List<int>.from(json["setData"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "exerciseId": exerciseId == null ? null : exerciseId,
        "setData":
            setData == null ? null : List<dynamic>.from(setData.map((x) => x)),
      };
}
