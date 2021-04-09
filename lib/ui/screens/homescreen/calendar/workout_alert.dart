import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_tracker/bloc/exercise_bloc/exercise_bloc.dart';
import 'package:workout_tracker/bloc/user_workout_bloc/user_workout_bloc.dart';
import 'package:workout_tracker/models/exercise.dart';
import 'package:workout_tracker/models/user_workout.dart';
import 'package:workout_tracker/ui/widgets/common_widgets.dart';
import 'package:workout_tracker/ui/widgets/scroll_to_index.dart';

class WorkoutAlert extends StatefulWidget {
  final UserWorkout userWorkout;

  const WorkoutAlert({Key key, @required this.userWorkout}) : super(key: key);
  @override
  _WorkoutAlertState createState() => _WorkoutAlertState();
}

class _WorkoutAlertState extends State<WorkoutAlert> {
  UserWorkoutBloc _userWorkoutBloc;
  ExerciseBloc _exerciseBloc;

  int selectedIndex = 0;
  String duration;

  final AutoScrollController _scrollController = AutoScrollController(
    axis: Axis.horizontal,
  );

  @override
  void initState() {
    super.initState();
    _exerciseBloc = BlocProvider.of<ExerciseBloc>(context);
    _exerciseBloc.add(LoadExercises());
    _userWorkoutBloc = BlocProvider.of<UserWorkoutBloc>(context);
    _userWorkoutBloc.add(LoadDetailUserWorkout(widget.userWorkout));

    duration = widget.userWorkout.endTime
            ?.difference(widget.userWorkout.startTime)
            ?.inMinutes
            .toString() ??
        "";
    if (duration.isNotEmpty) duration += " mins";
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<List<int>> buildExerciseGrid(
      List<Map<DateTime, List<int>>> previousData) {
    List<List<int>> mainData = [];
    for (var i = 0;
        i < widget.userWorkout.exerciseData[selectedIndex].setData.length;
        i++) {
      List<int> setData = [];
      for (var singleData in previousData) {
        if (i < singleData.values.first.length) {
          setData.add(singleData.values.first[i]);
        } else {
          setData.add(null);
        }
      }
      mainData.add(setData);
    }
    return mainData;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
        child: Center(
          child: Material(
            color: Theme.of(context).dialogBackgroundColor,
            elevation: 24.0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(4.0),
              ),
            ),
            child: BlocBuilder<ExerciseBloc, ExerciseState>(
                cubit: _exerciseBloc,
                buildWhen: (previous, current) => true,
                builder: (context, ExerciseState exerciseState) {
                  if (exerciseState is ExerciseLoaded) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        cardHeader(context),
                        BlocBuilder<UserWorkoutBloc, UserWorkoutState>(
                            cubit: _userWorkoutBloc,
                            builder: (context, state) {
                              if (state is DetailUserWorkout) {
                                int selectedExerciseId = widget.userWorkout
                                    .exerciseData[selectedIndex].exerciseId;
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        currentData(
                                          state,
                                          selectedExerciseId,
                                          exerciseState,
                                          context,
                                        ),
                                        if (state.previousData[
                                                selectedExerciseId] !=
                                            null)
                                          ...List.generate(
                                            state
                                                .previousData[
                                                    selectedExerciseId]
                                                .length,
                                            (outerIndex) {
                                              int days = DateTime.now()
                                                  .difference(state
                                                      .previousData[
                                                          selectedExerciseId]
                                                          [outerIndex]
                                                      .keys
                                                      .first)
                                                  .inDays;
                                              String dur = "";
                                              if (days == 0) {
                                                if (DateTime.now().day ==
                                                    state
                                                        .previousData[
                                                            selectedExerciseId]
                                                            [outerIndex]
                                                        .keys
                                                        .first
                                                        .day) {
                                                  dur = "Today";
                                                } else {
                                                  dur = "Yesterday";
                                                }
                                              } else if (days == 1) {
                                                dur = "Yesterday";
                                              } else if (days < 60) {
                                                dur = "${days} days ago";
                                              } else {
                                                dur =
                                                    "${days ~/ 60} months ago";
                                              }
                                              return previousData(
                                                dur,
                                                context,
                                                state,
                                                selectedExerciseId,
                                                outerIndex,
                                              );
                                            },
                                          )
                                      ]),
                                );
                              } else {
                                return Container();
                              }
                            }),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: _scrollController,
                            child: Row(
                              children: List.generate(
                                widget.userWorkout.exerciseData.length,
                                (index) {
                                  Exercise exercise;
                                  int exerciseIndex = exerciseState.exercises
                                      .indexWhere((element) =>
                                          element.id ==
                                          widget.userWorkout.exerciseData[index]
                                              .exerciseId);
                                  if (exerciseIndex >= 0) {
                                    exercise =
                                        exerciseState.exercises[exerciseIndex];
                                  }
                                  return AutoScrollTag(
                                    key: ValueKey(index),
                                    controller: _scrollController,
                                    index: index,
                                    child: CommonWidget.selectableCard(
                                      text: exercise.name,
                                      context: context,
                                      isSelected: index == selectedIndex,
                                      onSelectionChange: (selected) {
                                        if (selected) {
                                          if (index > selectedIndex)
                                            _scrollController
                                                .scrollToIndex(index + 1);
                                          else
                                            _scrollController
                                                .scrollToIndex(index - 1);
                                          setState(() {
                                            selectedIndex = index;
                                          });
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                }),
          ),
        ),
      ),
    );
  }

  Row previousData(String dur, BuildContext context, DetailUserWorkout state,
      int selectedExerciseId, int outerIndex) {
    return Row(children: [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 6.0,
          ),
          child: Text(
            dur,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.caption,
            maxLines: 1,
          ),
        ),
      ),
      ...List.generate(
        widget.userWorkout.exerciseData[selectedIndex].setData.length,
        (index) => Expanded(
          child: Text(
            index <
                    state.previousData[selectedExerciseId][outerIndex].values
                        .first.length
                ? state.previousData[selectedExerciseId][outerIndex].values
                    .first[index]
                    .toString()
                : "-",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ]);
  }

  Widget goal(
    int exerciseId,
    ExerciseLoaded exerciseLoaded,
    int setLength,
  ) {
    Exercise exercise;
    int exerciseIndex = exerciseLoaded.exercises
        .indexWhere((element) => element.id == exerciseId);
    if (exerciseIndex >= 0) {
      exercise = exerciseLoaded.exercises[exerciseIndex];
    }
    return Row(
      children: [
        Expanded(
          child: Center(
            child: Text(
              "Goal",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.caption,
              maxLines: 1,
            ),
          ),
        ),
        ...List.generate(setLength, (index) {
          if (index < exercise.goals.length)
            return Expanded(
              child: Text(
                exercise.goals[index].toString(),
                textAlign: TextAlign.center,
              ),
            );
          else
            return Expanded(
              child: const Text(
                "-",
                textAlign: TextAlign.center,
              ),
            );
        })
      ],
    );
  }

  Widget currentData(DetailUserWorkout state, int selectedExerciseId,
      ExerciseLoaded exerciseLoaded, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Spacer(),
            ...List.generate(
              widget.userWorkout.exerciseData[selectedIndex].setData.length,
              (index) => Expanded(
                child: Center(
                    child: Text(
                  "Set ${index + 1}",
                  style: Theme.of(context).textTheme.caption,
                )),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        goal(
          widget.userWorkout.exerciseData[selectedIndex].exerciseId,
          exerciseLoaded,
          widget.userWorkout.exerciseData[selectedIndex].setData.length,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  "Current",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.caption,
                  maxLines: 1,
                ),
              ),
            ),
            ...List.generate(
              widget.userWorkout.exerciseData[selectedIndex].setData.length,
              (index) => Expanded(
                child: Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).buttonColor,
                  ),
                  child: Text(
                    widget
                        .userWorkout.exerciseData[selectedIndex].setData[index]
                        .toString(),
                    style: Theme.of(context).textTheme.subtitle1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Hero cardHeader(BuildContext context) {
    return Hero(
      tag: widget.userWorkout.id,
      child: Container(
        color: Theme.of(context).accentColor,
        width: double.maxFinite,
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.userWorkout?.workout?.name ?? "All",
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(color: Colors.white),
            ),
            Text(
              duration,
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
