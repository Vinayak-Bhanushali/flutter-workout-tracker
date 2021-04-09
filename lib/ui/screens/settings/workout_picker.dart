import 'package:flutter/material.dart';
import 'package:workout_tracker/models/workout.dart';
import 'package:workout_tracker/ui/widgets/custom_choice_chip.dart';

class WorkoutPicker extends StatefulWidget {
  final List<Workout> allWorkouts;
  final Set<int> selectedWorkoutIds;
  final Function(Set<int> selectedWorkoutIds) updateWorkoutList;

  const WorkoutPicker({
    Key key,
    this.allWorkouts,
    this.selectedWorkoutIds,
    this.updateWorkoutList,
  }) : super(key: key);
  @override
  _WorkoutPickerState createState() => _WorkoutPickerState();
}

class _WorkoutPickerState extends State<WorkoutPicker> {
  Set<int> selectedWorkoutIds;

  @override
  void initState() {
    super.initState();
    selectedWorkoutIds = widget.selectedWorkoutIds;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 10,
        children: widget.allWorkouts.map(
          (workout) {
            return CustomChoiceChip(
              label: workout.name,
              selected: selectedWorkoutIds.contains(workout.id),
              onSelected: (selected) {
                if (selected)
                  selectedWorkoutIds.add(workout.id);
                else
                  selectedWorkoutIds.remove(workout.id);
                setState(() {});

                widget.updateWorkoutList(selectedWorkoutIds);
              },
            );
          },
        ).toList(),
      ),
    );
  }
}
