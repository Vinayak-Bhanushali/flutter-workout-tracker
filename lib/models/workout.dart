import 'package:meta/meta.dart';
import 'dart:convert';

class Workout {
  Workout({
    this.id,
    @required this.name,
  });

  int id;
  String name;

  factory Workout.fromRawJson(String str) => Workout.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
      };
}
