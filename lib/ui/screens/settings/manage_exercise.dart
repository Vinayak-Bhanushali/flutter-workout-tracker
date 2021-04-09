import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_tracker/bloc/exercise_bloc/exercise_bloc.dart';
import 'package:workout_tracker/models/exercise.dart';
import 'package:workout_tracker/models/enums.dart';
import 'package:workout_tracker/models/workout.dart';
import 'package:workout_tracker/ui/screens/settings/exercise_dialog.dart';
import 'package:workout_tracker/ui/screens/settings/goals_dialog.dart';
import 'package:workout_tracker/ui/screens/settings/workout_picker.dart';
import 'package:workout_tracker/ui/widgets/common_widgets.dart';
import 'package:workout_tracker/ui/widgets/custom_dialogue.dart';
import 'package:workout_tracker/uitilities/custom_extensions.dart';

class ManageExercise extends StatefulWidget {
  final Workout selectedWorkout;
  final List<Workout> allWorkouts;

  const ManageExercise({
    Key key,
    this.selectedWorkout,
    this.allWorkouts,
  }) : super(key: key);

  @override
  _ManageExerciseState createState() => _ManageExerciseState();
}

class _ManageExerciseState extends State<ManageExercise> {
  ExerciseBloc _exerciseBloc;
  String _title = "";

  @override
  void initState() {
    super.initState();
    _exerciseBloc = BlocProvider.of<ExerciseBloc>(context);
    _exerciseBloc.add(LoadExercises(
      workout: widget.selectedWorkout,
    ));
    _title = widget.selectedWorkout == null
        ? "All Exercises"
        : "${widget.selectedWorkout.name} Exercises";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<ExerciseBloc, ExerciseState>(
          cubit: _exerciseBloc,
          builder: (context, state) {
            if (state is ExerciseLoaded)
              return ListView.builder(
                itemCount: state.exercises.length,
                padding: const EdgeInsets.only(bottom: 80),
                itemBuilder: (context, index) => exerciseCard(
                  state.exercises[index],
                  context,
                ),
              );
            else
              return Center(
                child: CircularProgressIndicator(),
              );
          },
        ),
      ),
      floatingActionButton: widget.selectedWorkout == null
          ? null
          : FloatingActionButton(
              onPressed: () async {
                var result = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Add Exercise"),
                    content: ExerciseDialog(),
                  ),
                );
                if (result is Exercise) {
                  // Add id of selected workout when adding new exercise. Not availbale in all workouts
                  result.workoutIDs.add(widget.selectedWorkout.id);
                  _exerciseBloc.add(
                    InsertExercise(result, widget.selectedWorkout),
                  );
                }
              },
              child: Icon(Icons.add),
            ),
    );
  }

  Dismissible exerciseCard(Exercise exercise, BuildContext context) {
    return CommonWidget.cardDismissible(
      onDismissed: () => _exerciseBloc.add(
        DeleteExercise(
          exercise,
          widget.selectedWorkout,
        ),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: Theme.of(context).textTheme.subtitle1,
                      textAlign: TextAlign.start,
                    ),
                    Divider(),
                    workoutList(context, exercise),
                    InkWell(
                      onTap: () async {
                        var result = await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => AlertDialog(
                            content: GoalDialog(
                              goals: exercise.goals,
                            ),
                          ),
                        );
                        if (result != null && result is List<int>) {
                          exercise.goals = result;
                          _exerciseBloc.add(
                            UpdateExercise(exercise, widget.selectedWorkout),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          Text("Goals:".addFourSpace()),
                          Flexible(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: exercise.goals
                                      .map(
                                        (e) =>
                                            Text(e.toString().addFourSpace()),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit,
                ),
                onPressed: () async {
                  var result = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Update Exercise"),
                      content: ExerciseDialog(
                        exercise: exercise,
                      ),
                    ),
                  );
                  if (result is Exercise) {
                    _exerciseBloc.add(
                      UpdateExercise(result, widget.selectedWorkout),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardBody(BuildContext context, Exercise exercise) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                workoutList(context, exercise),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () async {
                    dynamic result = await CustomDialog.inputDialog(
                      title: "Enter notes",
                      context: context,
                      textInputType: TextInputType.multiline,
                      defaultText: exercise.note,
                      maxLines: 4,
                    );
                    if (result != null && result != '') {
                      exercise.note = result;
                      _exerciseBloc.add(
                        UpdateExercise(
                          exercise,
                          widget.selectedWorkout,
                        ),
                      );
                    }
                  },
                  child: Text(
                    exercise.note.isEmpty ? "Add note" : exercise.note,
                    style: Theme.of(context).textTheme.caption,
                    textAlign: TextAlign.left,
                    maxLines: 4,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                child: Icon(Icons.play_circle_fill),
                onTap: () async {
                  dynamic result = await CustomDialog.inputDialog(
                    title: "YouTube Link",
                    defaultText: exercise.youtubeUrl,
                    context: context,
                    regExp: RegExp(
                      r"^(https?\:\/\/)?(www\.)?(youtube\.com|youtu\.?be)\/.+$",
                    ),
                    invalidInputMessage: "Invalid Youtube Url",
                  );
                  if (result != null && result != '') {
                    exercise.youtubeUrl = result;
                    _exerciseBloc.add(
                      UpdateExercise(
                        exercise,
                        widget.selectedWorkout,
                      ),
                    );
                  }
                },
              ),
              InkWell(
                onTap: () {
                  exercise.dailyExercise = !exercise.dailyExercise;
                  UpdateExercise(
                    exercise,
                    widget.selectedWorkout,
                  );
                },
                child: Row(
                  children: [
                    Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: exercise.dailyExercise,
                      onChanged: (value) {
                        exercise.dailyExercise = value;
                        UpdateExercise(
                          exercise,
                          widget.selectedWorkout,
                        );
                      },
                    ),
                    Text(
                      "Daily Exercise",
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InkWell workoutList(BuildContext context, Exercise exercise) {
    return InkWell(
      onTap: () async {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Select workouts for ${exercise.name}"),
              actions: [
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("CLOSE"))
              ],
              content: WorkoutPicker(
                allWorkouts: widget.allWorkouts,
                selectedWorkoutIds: exercise.workoutIDs,
                updateWorkoutList: (selectedWorkoutIds) {
                  exercise.workoutIDs = selectedWorkoutIds;
                  _exerciseBloc.add(
                    UpdateExercise(
                      exercise,
                      widget.selectedWorkout,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Workouts:   ",
              style: Theme.of(context).textTheme.bodyText2,
            ),
            Expanded(
              child: Wrap(
                runSpacing: 6,
                children: exercise.workoutIDs
                    .map(
                      (e) => Text(
                        widget.allWorkouts
                                .firstWhere((element) => element.id == e)
                                .name +
                            "   ",
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cardHeader(BuildContext context, Exercise exercise) {
    return Container(
      color: Theme.of(context).cardColor,
      width: double.maxFinite,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () async {
              dynamic result = await CustomDialog.inputDialog(
                title: "Enter Name",
                context: context,
                defaultText: exercise.name,
              );
              if (result != null && result != '') {
                exercise.name = result;
                _exerciseBloc.add(
                  UpdateExercise(
                    exercise,
                    widget.selectedWorkout,
                  ),
                );
              }
            },
            child: Text(
              exercise.name,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Row(
            children: [
              InkWell(
                onTap: () {
                  exercise.unit = Unit.REPS;
                  _exerciseBloc.add(
                    UpdateExercise(
                      exercise,
                      widget.selectedWorkout,
                    ),
                  );
                },
                child: SizedBox(
                  height: 16,
                  child: Row(
                    children: [
                      Radio(
                        value: Unit.REPS,
                        groupValue: exercise.unit,
                        onChanged: (unit) {
                          exercise.unit = unit;
                          _exerciseBloc.add(
                            UpdateExercise(
                              exercise,
                              widget.selectedWorkout,
                            ),
                          );
                        },
                      ),
                      Text(
                        unitFullFormValues.reverse[Unit.REPS],
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  exercise.unit = Unit.SECS;
                  _exerciseBloc.add(
                    UpdateExercise(
                      exercise,
                      widget.selectedWorkout,
                    ),
                  );
                },
                child: SizedBox(
                  height: 16,
                  child: Row(
                    children: [
                      Radio(
                        value: Unit.SECS,
                        groupValue: exercise.unit,
                        onChanged: (unit) {
                          exercise.unit = unit;
                          _exerciseBloc.add(
                            UpdateExercise(
                              exercise,
                              widget.selectedWorkout,
                            ),
                          );
                        },
                      ),
                      Text(
                        unitFullFormValues.reverse[Unit.SECS],
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
