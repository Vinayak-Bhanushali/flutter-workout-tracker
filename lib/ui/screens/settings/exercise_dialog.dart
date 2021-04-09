import 'package:flutter/material.dart';
import 'package:workout_tracker/models/exercise.dart';
import 'package:workout_tracker/models/enums.dart';

class ExerciseDialog extends StatefulWidget {
  final Exercise exercise;
  const ExerciseDialog({Key key, this.exercise}) : super(key: key);

  @override
  _AddExerciseState createState() => _AddExerciseState();
}

class _AddExerciseState extends State<ExerciseDialog> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _note = TextEditingController();

  Exercise exercise;
  @override
  void initState() {
    super.initState();
    exercise = widget.exercise ??
        Exercise(
          unit: Unit.REPS,
          name: null,
          workoutIDs: {},
          youtubeUrl: null,
        );
    _name.text = exercise.name;
    _note.text = exercise.note;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          autofocus: true,
          controller: _name,
          decoration: InputDecoration(labelText: "Exercise Name"),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              "Unit",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            InkWell(
              child: Row(
                children: [
                  Radio(
                    value: Unit.REPS,
                    groupValue: exercise.unit,
                    onChanged: (newUnit) {
                      setState(() {
                        exercise.unit = newUnit;
                      });
                    },
                  ),
                  Text(unitFullFormValues.reverse[Unit.REPS])
                ],
              ),
            ),
            InkWell(
              child: Row(
                children: [
                  Radio(
                    value: Unit.SECS,
                    groupValue: exercise.unit,
                    onChanged: (newUnit) {
                      setState(() {
                        exercise.unit = newUnit;
                      });
                    },
                  ),
                  Text(unitFullFormValues.reverse[Unit.SECS])
                ],
              ),
            ),
            // Flexible(
            //   child: RadioListTile(
            //     value: Unit.REPS,
            //     dense: true,
            //     groupValue: exercise.unit,
            //     onChanged: (newUnit) {
            //       setState(() {
            //         exercise.unit = newUnit;
            //       });
            //     },
            //     title: Text(unitFullFormValues.reverse[Unit.REPS]),
            //   ),
            // ),
            // Flexible(
            //   child: RadioListTile(
            //     value: Unit.SECS,
            //     dense: true,
            //     groupValue: exercise.unit,
            //     onChanged: (newUnit) {
            //       setState(() {
            //         exercise.unit = newUnit;
            //       });
            //     },
            //     title: Text(unitFullFormValues.reverse[Unit.SECS]),
            //   ),
            // )
          ],
        ),
        TextField(
          controller: _note,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(labelText: "Notes"),
          textCapitalization: TextCapitalization.sentences,
          minLines: 1,
          maxLines: 2,
        ),
        const SizedBox(
          height: 10,
        ),
        InkWell(
          onTap: () {
            setState(() {
              exercise.dailyExercise = !exercise.dailyExercise;
            });
          },
          child: Row(
            children: [
              Checkbox(
                value: exercise.dailyExercise,
                onChanged: (value) {
                  setState(() {
                    exercise.dailyExercise = value;
                  });
                },
              ),
              Text("Daily Exercise"),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        ElevatedButton(
          onPressed: () {
            exercise.name = _name.text;
            exercise.note = _note.text;
            Navigator.of(context).pop(exercise);
          },
          child: const Text("DONE"),
        ),
      ],
    );
  }
}
