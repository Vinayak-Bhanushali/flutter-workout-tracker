import 'package:flutter/material.dart';
import 'package:workout_tracker/models/exercise.dart';
import 'package:workout_tracker/ui/widgets/custom_choice_chip.dart';

class ExercisePicker extends StatefulWidget {
  final List<Exercise> workoutExercises;
  final List<Exercise> otherExercises;
  final List<int> selectedExercises;
  final Function(Exercise exercise) addExercise;
  final Function(Exercise exercise) removeExercise;
  const ExercisePicker({
    Key key,
    @required this.workoutExercises,
    @required this.otherExercises,
    @required this.selectedExercises,
    @required this.addExercise,
    @required this.removeExercise,
  }) : super(key: key);
  @override
  _ExercisePickerState createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<ExercisePicker> {
  List<int> selectedExercises;

  @override
  void initState() {
    super.initState();
    selectedExercises = widget.selectedExercises;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            spacing: 10,
            children: widget.workoutExercises
                .map(
                  (e) => CustomChoiceChip(
                    label: e.name,
                    selected: selectedExercises.contains(e.id),
                    onSelected: (selected) {
                      if (selected) {
                        selectedExercises.add(e.id);
                        widget.addExercise(e);
                      } else {
                        selectedExercises.remove(e.id);
                        widget.removeExercise(e);
                      }
                      setState(() {});
                    },
                  ),
                )
                .toList(),
          ),
          if (widget.otherExercises.length >= 1) ...[
            Divider(),
            Wrap(
              spacing: 10,
              children: widget.otherExercises
                  .map(
                    (e) => ChoiceChip(
                      label: Text(
                        e.name,
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyText1.color),
                      ),
                      selected: selectedExercises.contains(e.id),
                      selectedColor: Theme.of(context).accentColor,
                      onSelected: (selected) {
                        if (selected) {
                          selectedExercises.add(e.id);
                          widget.addExercise(e);
                        } else {
                          selectedExercises.remove(e.id);
                          widget.removeExercise(e);
                        }
                        setState(() {});
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
