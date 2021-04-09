import 'package:meta/meta.dart';
import 'dart:convert';

import 'package:workout_tracker/models/enums.dart';

class Exercise {
  Exercise({
    this.id,
    @required this.unit,
    @required this.name,
    @required this.workoutIDs,
    @required this.youtubeUrl,
    this.goals = const [],
    this.frequency = 0,
    this.note,
    this.dailyExercise = false,
  });

  int id;
  Unit unit;
  String name;
  int frequency;
  Set<int> workoutIDs;
  List<int> goals;
  String youtubeUrl;
  String note;
  bool dailyExercise;

  factory Exercise.fromRawJson(String str) =>
      Exercise.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json["id"] == null ? null : json["id"],
        unit: json["unit"] == null
            ? Unit.REPS
            : unitFullFormValues.map[json["unit"]],
        name: json["name"] == null ? null : json["name"],
        frequency: json["frequency"] == null ? null : json["frequency"],
        workoutIDs: json["workoutIDs"] == null
            ? null
            : Set<int>.from(json["workoutIDs"].map((x) => x)),
        goals: json["goals"] == null
            ? null
            : List<int>.from(json["goals"].map((x) => x)),
        youtubeUrl: json["youtubeUrl"] == null ? null : json["youtubeUrl"],
        note: json["note"] == null ? null : json["note"],
        dailyExercise:
            json["dailyExercise"] == null ? null : json["dailyExercise"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "unit": unit == null ? null : unitFullFormValues.reverse[unit],
        "name": name == null ? null : name,
        "frequency": frequency == null ? null : frequency,
        "workoutIDs": workoutIDs == null
            ? null
            : List<dynamic>.from(workoutIDs.map((x) => x)),
        "goals": goals == null ? null : List<dynamic>.from(goals.map((x) => x)),
        "youtubeUrl": youtubeUrl == null ? null : youtubeUrl,
        "note": note == null ? null : note,
        "dailyExercise": dailyExercise == null ? null : dailyExercise,
      };
}
