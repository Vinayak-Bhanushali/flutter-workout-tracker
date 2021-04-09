import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_tracker/bloc/exercise_bloc/exercise_bloc.dart';
import 'package:workout_tracker/bloc/timeline_bloc/timeline_bloc.dart';
import 'package:workout_tracker/bloc/user_workout_bloc/user_workout_bloc.dart';
import 'package:workout_tracker/models/exercise.dart';
import 'package:workout_tracker/models/timeline.dart';
import 'package:workout_tracker/models/user_workout.dart';
import 'package:workout_tracker/ui/screens/workout/timeline_image_dialog.dart';
import 'package:workout_tracker/ui/widgets/custom_dialogue.dart';
import 'package:workout_tracker/ui/widgets/particle_shooter.dart';
import 'package:workout_tracker/uitilities/route_generator.dart';
import 'package:workout_tracker/uitilities/widget_helper.dart';

class FinishWorkout extends StatefulWidget {
  final Timeline timeline;

  const FinishWorkout({Key key, this.timeline}) : super(key: key);

  @override
  _FinishWorkoutState createState() => _FinishWorkoutState();
}

class _FinishWorkoutState extends State<FinishWorkout> {
  UserWorkoutBloc _userWorkoutBloc;
  ExerciseBloc _exerciseBloc;
  TimelineBloc _timelineBloc;
  Timeline _timeline;
  bool newGoalAcheieved = false;
  int goalIndex;
  final CarouselController _carouselController = CarouselController();

  @override
  void initState() {
    super.initState();
    _userWorkoutBloc = BlocProvider.of<UserWorkoutBloc>(context);
    _exerciseBloc = BlocProvider.of<ExerciseBloc>(context);
    _timeline = widget.timeline;
    // Clear goals if users comes again from workout detail screen
    _timeline.goalsData.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Add to timeline if atleast one goal is completed
      if (_timelineBloc == null && _timeline.goalsData.isNotEmpty) {
        _timelineBloc = BlocProvider.of<TimelineBloc>(context);
        // if user is coming first time form detail workout add new timeline
        if (_timeline.id == null)
          _timelineBloc.add(
            InsertTimeline(_timeline),
          );
        // else update existing
        else
          _timelineBloc.add(
            UpdateTimeline(_timeline),
          );
        setState(() {
          newGoalAcheieved = true;
        });
        if (goalIndex != null) _carouselController.jumpToPage(goalIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await CustomDialog.yesNoDialog(
          title: "Confirm",
          description: "Go back to workout?",
          context: context,
        );
      },
      child: BlocListener(
        cubit: _userWorkoutBloc,
        listener: (context, state) {
          if (state is UserWorkoutFinish)
            Navigator.of(context).pushNamedAndRemoveUntil(
              RouteGenerator.home,
              (route) => false,
            );
        },
        child: BlocBuilder<UserWorkoutBloc, UserWorkoutState>(
          cubit: _userWorkoutBloc,
          builder: (context, state) {
            if (state is UserWorkoutActive) {
              String duration = state.userWorkout.endTime
                      ?.difference(state.userWorkout.startTime)
                      ?.inMinutes
                      .toString() ??
                  "";
              if (duration.isNotEmpty) duration += " minutes";
              return Scaffold(
                body: SafeArea(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: BlocBuilder<ExerciseBloc, ExerciseState>(
                          cubit: _exerciseBloc,
                          builder: (context, exerciseState) {
                            if (exerciseState is ExerciseLoadedForUserWorkout) {
                              state.userWorkout.exerciseData.sort((a, b) {
                                Exercise exerciseA;

                                int exerciseIndexA = exerciseState
                                    .workoutExercises
                                    .indexWhere((element) =>
                                        element.id == a.exerciseId);
                                if (exerciseIndexA >= 0) {
                                  exerciseA = exerciseState
                                      .workoutExercises[exerciseIndexA];
                                } else {
                                  exerciseIndexA = exerciseState.otherExercises
                                      .indexWhere((element) =>
                                          element.id == a.exerciseId);
                                  if (exerciseIndexA >= 0) {
                                    exerciseA = exerciseState
                                        .otherExercises[exerciseIndexA];
                                  }
                                }
                                if (exerciseA.dailyExercise)
                                  return 1;
                                else
                                  return -1;
                              });

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: header(
                                      context,
                                      state,
                                      exerciseState,
                                      duration,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Flexible(
                                    flex: 3,
                                    child:
                                        insights(context, state, exerciseState),
                                  ),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    flex: 5,
                                    child: goals(context, state, exerciseState),
                                  ),
                                ],
                              );
                            } else
                              return Container();
                          },
                        ),
                      ),
                      if (newGoalAcheieved) ...[
                        ParticleShooter(
                          alignment: Alignment.bottomLeft,
                        ),
                        ParticleShooter(
                          alignment: Alignment.bottomRight,
                        ),
                      ],
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: () async {
                    if (_timelineBloc == null) {
                      // Add to timeline if no goals have been completed but user want to add images
                      _timelineBloc = BlocProvider.of<TimelineBloc>(context);
                      _timelineBloc.add(
                        InsertTimeline(_timeline),
                      );
                    }
                    await showDialog(
                      context: context,
                      builder: (context) => BlocProvider.value(
                        value: _timelineBloc,
                        child: TimelineImageDialog(),
                      ),
                    );
                    // Remove from timeline if the data is empty
                    // if (_timeline.goalsData.isEmpty &&
                    //     _timeline.imageData.isEmpty)
                    //   _timelineBloc.add(DeleteTimeline(_timeline));
                  },
                  label: Text("Add Images"),
                  icon: Icon(Icons.add_a_photo_rounded),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  Column header(BuildContext context, UserWorkoutActive state,
      ExerciseLoadedForUserWorkout exerciseState, String duration) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Great Job",
              style: Theme.of(context).textTheme.headline4,
              textAlign: TextAlign.center,
            ),
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Set<Exercise> updatedExercises = Set();

                // Remove from timeline if the data is empty
                if (_timelineBloc != null &&
                    _timeline.goalsData.isEmpty &&
                    _timeline.imageData.isEmpty) {
                  _timelineBloc.add(
                    DeleteTimeline(_timeline),
                  );
                } else {
                  // if goals completed auto increment its value
                  for (var goal in _timeline.goalsData) {
                    Exercise exercise =
                        exerciseState.workoutExercises.firstWhere(
                      (element) => element.name == goal.exerciseName,
                      orElse: () => null,
                    );
                    if (exercise == null)
                      exercise = exerciseState.otherExercises.firstWhere(
                        (element) => element.name == goal.exerciseName,
                        orElse: () => null,
                      );
                    if (exercise != null) {
                      // increment goals by 20%
                      exercise.goals[goal.setNo - 1] +=
                          (exercise.goals[goal.setNo - 1] * 0.2).floor();
                      updatedExercises.add(exercise);
                    }
                  }
                }
                _userWorkoutBloc
                    .add(FinishWorkoutAndUpdateGoals(updatedExercises));
              },
            ),
          ],
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.userWorkout.workout?.name ?? "All",
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.accessibility_new),
                        const SizedBox(width: 10),
                        Text(
                          "${state.userWorkout.exerciseData.length} Exercises",
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Row(
                      children: [
                        const Icon(Icons.timer),
                        const SizedBox(width: 10),
                        Text(duration),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Column goals(BuildContext context, UserWorkoutActive state,
      ExerciseLoadedForUserWorkout exerciseState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Goals",
          style: Theme.of(context).textTheme.headline6.copyWith(
                color: Theme.of(context).textTheme.headline4.color,
              ),
        ),
        CarouselSlider(
          carouselController: _carouselController,
          items: List.generate(state.userWorkout.exerciseData.length, (index) {
            Exercise exercise;
            int exerciseIndex = exerciseState.workoutExercises.indexWhere(
                (element) =>
                    element.id ==
                    state.userWorkout.exerciseData[index].exerciseId);
            if (exerciseIndex >= 0) {
              exercise = exerciseState.workoutExercises[exerciseIndex];
            } else {
              exerciseIndex = exerciseState.otherExercises.indexWhere(
                  (element) =>
                      element.id ==
                      state.userWorkout.exerciseData[index].exerciseId);
              exercise = exerciseState.otherExercises[exerciseIndex];
            }
            return goalCard(
              index,
              state.userWorkout.exerciseData[index],
              exercise,
              context,
            );
          }),
          options: CarouselOptions(
            initialPage: 0,
            enableInfiniteScroll: true,
            enlargeCenterPage: true,
            viewportFraction: 0.6,
            aspectRatio: 3 / 2,
          ),
        ),
      ],
    );
  }

  Column insights(
    BuildContext context,
    UserWorkoutActive state,
    ExerciseLoadedForUserWorkout exerciseState,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Insights",
          style: Theme.of(context).textTheme.headline6.copyWith(
                color: Theme.of(context).textTheme.headline4.color,
              ),
        ),
        const SizedBox(height: 10),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: WidgetHelper.twoElements(
              state.userWorkout.exerciseData.map((e) {
                Exercise exercise;
                int exerciseIndex = exerciseState.workoutExercises
                    .indexWhere((element) => element.id == e.exerciseId);
                if (exerciseIndex >= 0) {
                  exercise = exerciseState.workoutExercises[exerciseIndex];
                } else {
                  exerciseIndex = exerciseState.otherExercises
                      .indexWhere((element) => element.id == e.exerciseId);
                  exercise = exerciseState.otherExercises[exerciseIndex];
                }
                return insightCard(e, exercise, context, state);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Container goalCard(
    int index,
    ExerciseDatum exerciseDatum,
    Exercise exercise,
    BuildContext context,
  ) {
    bool isGoalAcheived = false;
    for (var i = 0; i < exerciseDatum.setData.length; i++) {
      if (i < exercise.goals.length &&
          exerciseDatum.setData[i] >= exercise.goals[i]) {
        isGoalAcheived = true;
        GoalData goalData = GoalData(
          exerciseName: exercise.name,
          setNo: i + 1,
          value: exercise.goals[i],
          unit: exercise.unit,
        );
        // ignore if already added
        if (!_timeline.goalsData.contains(goalData))
          _timeline.goalsData.add(goalData);
      }
    }
    if (goalIndex == null && isGoalAcheived) goalIndex = index;
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: isGoalAcheived ? Colors.green : Theme.of(context).dividerColor,
      ),
      child: Column(
        children: [
          Text(
            exercise.name,
            style: Theme.of(context).textTheme.headline6.copyWith(
                color: isGoalAcheived
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyText1.color),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Expanded(
                child: Center(
                    child: Text(
                  "Set",
                  style: Theme.of(context).textTheme.caption.copyWith(
                      color: isGoalAcheived
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyText1.color),
                )),
              ),
              Expanded(
                child: Center(
                    child: Text(
                  "Current",
                  style: Theme.of(context).textTheme.caption.copyWith(
                      color: isGoalAcheived
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyText1.color),
                )),
              ),
              Expanded(
                child: Center(
                    child: Text(
                  "Goal",
                  style: Theme.of(context).textTheme.caption.copyWith(
                      color: isGoalAcheived
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyText1.color),
                )),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  exerciseDatum.setData.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            "${index + 1}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: isGoalAcheived
                                    ? Colors.white
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            exerciseDatum.setData[index].toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: index < exercise.goals.length &&
                                        exerciseDatum.setData[index] >=
                                            exercise.goals[index]
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isGoalAcheived
                                    ? Colors.white
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            exercise.goals.length <= index
                                ? "-"
                                : exercise.goals[index].toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: isGoalAcheived
                                    ? Colors.white
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Card insightCard(
    ExerciseDatum e,
    Exercise exercise,
    BuildContext context,
    UserWorkoutActive state,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              exercise.name,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  e.setData.length,
                  (index) {
                    double previousAverage = 0;
                    int count = 0;
                    List<int> prev = [];
                    state.previousData[exercise.id].forEach((element) {
                      if (element.length > index) {
                        prev.add(element[index]);
                        previousAverage += element[index];
                        count++;
                      }
                    });
                    previousAverage /= count;
                    double progress = 0;
                    if (count > 0 && previousAverage > 0)
                      progress = (e.setData[index] - previousAverage) *
                          100 /
                          (previousAverage);
                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            (index + 1).toString(),
                            style: Theme.of(context).textTheme.bodyText2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        SizedBox(
                          height: 24,
                          child: progress == 0
                              ? Text(
                                  "  -  ",
                                  style: Theme.of(context).textTheme.headline6,
                                )
                              : progress <= 0
                                  ? Text(
                                      " ▾ ${progress.toStringAsFixed(0)}% ",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .copyWith(
                                            color: Colors.red,
                                          ),
                                    )
                                  : Text(
                                      " ▴ ${progress.toStringAsFixed(0)}% ",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .copyWith(
                                            color: Colors.green,
                                          ),
                                    ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
