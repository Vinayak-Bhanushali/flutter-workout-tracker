import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock/wakelock.dart';
import 'package:workout_tracker/bloc/exercise_bloc/exercise_bloc.dart';
import 'package:workout_tracker/bloc/user_workout_bloc/user_workout_bloc.dart';
import 'package:workout_tracker/models/enums.dart';
import 'package:workout_tracker/models/exercise.dart';
import 'package:workout_tracker/models/timeline.dart';
import 'package:workout_tracker/models/user_workout.dart';
import 'package:workout_tracker/models/workout.dart';
import 'package:workout_tracker/ui/screens/workout/countdown.dart';
import 'package:workout_tracker/ui/screens/workout/exercise_picker.dart';
import 'package:workout_tracker/ui/screens/workout/stopwatch_timer.dart';
import 'package:workout_tracker/ui/widgets/common_widgets.dart';
import 'package:workout_tracker/ui/widgets/custom_dialogue.dart';
import 'package:workout_tracker/uitilities/route_generator.dart';
import 'package:workout_tracker/uitilities/custom_extensions.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class DetailWorkout extends StatefulWidget {
  final Workout workout;

  const DetailWorkout({Key key, @required this.workout}) : super(key: key);
  @override
  _DetailWorkoutState createState() => _DetailWorkoutState();
}

class _DetailWorkoutState extends State<DetailWorkout>
    with WidgetsBindingObserver {
  UserWorkoutBloc _userWorkoutBloc;
  ExerciseBloc _exerciseBloc;
  Timeline _timeline;

  @override
  void initState() {
    super.initState();
    _exerciseBloc = BlocProvider.of<ExerciseBloc>(context);
    _exerciseBloc.add(LoadExercisesForUserWorkout(
      workout: widget.workout,
    ));
    _userWorkoutBloc = BlocProvider.of<UserWorkoutBloc>(context);
    _userWorkoutBloc.add(InitalizeUserWorkout(
      widget.workout,
    ));
    _timeline = Timeline(
      workout: widget.workout,
      date: DateTime.now(),
      imageData: [],
      goalsData: [],
    );
    WidgetsBinding.instance.addObserver(this);
    Wakelock.enable();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _userWorkoutBloc.add(StopWorkout());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Wakelock.disable();
    super.dispose();
  }

  void showTimer(int seconds) {
    showDialog(
      context: context,
      child: AlertDialog(
        content: CountDown(
          seconds: seconds,
        ),
      ),
    );
  }

  Future<bool> stopWorkout(UserWorkoutActive userWorkoutActive) async {
    if (userWorkoutActive.userWorkout.exerciseData.isEmpty) {
      bool result = await CustomDialog.yesNoDialog(
        title: "Discard Workout",
        description:
            "No exercises tracked. Do you want to discard current workout?",
        context: context,
      );
      if (result) {
        _userWorkoutBloc.add(DeleteUserWorkout());
        Navigator.of(context).pop();
      }
      return result;
    } else {
      bool result = await CustomDialog.yesNoDialog(
        title: "Finish Workout",
        description: "Do you want to end current workout?",
        context: context,
      );
      if (result) {
        _userWorkoutBloc.add(StopWorkout());
        Navigator.of(context).pushNamed(
          RouteGenerator.finishWorkout,
          arguments: {
            '_userWorkoutBloc': _userWorkoutBloc,
            '_exerciseBloc': _exerciseBloc,
            '_timeline': _timeline,
          },
        );
      }
      return result;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseBloc, ExerciseState>(
      cubit: _exerciseBloc,
      builder: (context, exerciseState) {
        if (exerciseState is ExerciseLoadedForUserWorkout)
          return BlocBuilder<UserWorkoutBloc, UserWorkoutState>(
            cubit: _userWorkoutBloc,
            builder: (context, state) {
              if (state is UserWorkoutActive) {
                return WillPopScope(
                  onWillPop: () => stopWorkout(state),
                  child: Scaffold(
                    appBar: AppBar(
                      leading: countDownButton(context),
                      title: StopwatchTimer(),
                      centerTitle: true,
                      actions: [
                        FlatButton(
                          onPressed: () => stopWorkout(state),
                          child: Icon(
                            Icons.stop,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    body: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 80.0),
                          children: List.generate(
                            state.userWorkout.exerciseData.length,
                            (index) {
                              Exercise exercise;
                              int exerciseIndex = exerciseState.workoutExercises
                                  .indexWhere((element) =>
                                      element.id ==
                                      state.userWorkout.exerciseData[index]
                                          .exerciseId);
                              if (exerciseIndex >= 0) {
                                exercise = exerciseState
                                    .workoutExercises[exerciseIndex];
                              } else {
                                exerciseIndex = exerciseState.otherExercises
                                    .indexWhere((element) =>
                                        element.id ==
                                        state.userWorkout.exerciseData[index]
                                            .exerciseId);
                                exercise =
                                    exerciseState.otherExercises[exerciseIndex];
                              }
                              return workoutCard(
                                index,
                                exercise,
                                state.userWorkout.exerciseData[index],
                                _userWorkoutBloc,
                                state.previousData[state.userWorkout
                                        .exerciseData[index].exerciseId] ??
                                    [],
                                context,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    floatingActionButton: FloatingActionButton(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) => BlocProvider.value(
                            value: _userWorkoutBloc,
                            child: AlertDialog(
                              title: const Text("Select Exercises"),
                              content: ExercisePicker(
                                workoutExercises:
                                    exerciseState.workoutExercises,
                                otherExercises: exerciseState.otherExercises,
                                selectedExercises: state
                                    .userWorkout.exerciseData
                                    .map((e) => e.exerciseId)
                                    .toList(),
                                addExercise: (exercise) {
                                  _userWorkoutBloc.add(
                                    AddExerciseToUserWorkout(exercise.id),
                                  );
                                },
                                removeExercise: (exercise) {
                                  _userWorkoutBloc.add(
                                    RemoveExerciseFromUserWorkout(exercise.id),
                                  );
                                },
                              ),
                              actions: [
                                FlatButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text("CLOSE"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Icon(Icons.add),
                    ),
                  ),
                );
              } else
                return Container();
            },
          );
        else
          return Scaffold();
      },
    );
  }

  Widget countDownButton(BuildContext context) {
    return FlatButton(
      child: const Icon(
        Icons.timer,
        color: Colors.white,
      ),
      onPressed: () async {
        var result = await showDialog(
          context: context,
          builder: (context) {
            TextEditingController textEditingController =
                TextEditingController();
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Enter Seconds"),
                  TextField(
                    controller: textEditingController,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  IconButton(
                    icon: const Icon(Icons.play_arrow_rounded),
                    iconSize: 50,
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      Navigator.of(context).pop(textEditingController.text);
                    },
                  )
                ],
              ),
            );
          },
        );
        if (result != null && result != "") {
          showTimer(int.parse(result));
        }
      },
    );
  }

  Widget workoutCard(
    int exerciseIndex,
    Exercise exercise,
    ExerciseDatum exerciseDatum,
    UserWorkoutBloc userWorkoutBloc,
    List<List<int>> previousData,
    BuildContext context,
  ) {
    return CommonWidget.cardDismissible(
      onDismissed: () => _userWorkoutBloc.add(
        RemoveExerciseFromUserWorkout(exerciseDatum.exerciseId),
      ),
      child: Card(
        child: Column(
          children: [
            cardHeader(context, exercise, exerciseDatum, exerciseIndex),
            if (exerciseIndex == 0) cardBodyheadings(context),
            ...List.generate(
              exerciseDatum.setData.length,
              (setIndex) {
                List<int> prev = [];
                previousData.forEach((element) {
                  if (element.length > setIndex)
                    prev.add(element[setIndex]);
                  else
                    prev.add(null);
                });
                return setList(
                  exerciseIndex,
                  setIndex,
                  exerciseDatum.setData[setIndex],
                  exerciseDatum.exerciseId,
                  exercise.goals,
                  prev,
                  exercise.unit,
                  context,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Padding cardBodyheadings(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                "Set",
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                "Goal",
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Center(
              child: Text(
                "Current",
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Center(
              child: Text(
                "Previous",
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget cardHeader(
    BuildContext context,
    Exercise exercise,
    ExerciseDatum exerciseDatum,
    int exerciseIndex,
  ) {
    return Builder(builder: (context) {
      return Container(
        color: Theme.of(context).accentColor,
        width: double.maxFinite,
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "${exercise.name}",
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: Colors.white),
              ),
            ),
            if (exercise.youtubeUrl != null) ...[
              InkWell(
                child: const Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                ),
                onTap: () async {
                  YoutubePlayerController _controller = YoutubePlayerController(
                    initialVideoId: YoutubePlayerController.convertUrlToId(
                      exercise.youtubeUrl,
                    ),
                    params: YoutubePlayerParams(
                      autoPlay: true,
                      showVideoAnnotations: false,
                      showControls: true,
                      showFullscreenButton: true,
                    ),
                  );

                  showDialog(
                    context: context,
                    builder: (context) => YoutubePlayerIFrame(
                      controller: _controller,
                      aspectRatio: 3 / 4,
                    ),
                  );
                },
              ),
              const SizedBox(
                width: 20,
              ),
            ],
            if (exercise.note != null && exercise.note.isNotEmpty) ...[
              InkWell(
                child: const Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                onTap: () async {
                  Scaffold.of(context).removeCurrentSnackBar();
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        exercise.note,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                  );
                },
              ),
              const SizedBox(
                width: 20,
              ),
            ],
            InkWell(
              child: const Icon(Icons.add_circle, color: Colors.white),
              onTap: () {
                _userWorkoutBloc.add(
                  AddSetToExercise(
                    exerciseIndex,
                    0,
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  Widget setList(
    int exerciseIndex,
    int setIndex,
    int data,
    int exerciseId,
    List<int> goals,
    List<int> prev,
    Unit unit,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2.0),
              child: Text(
                (setIndex + 1).toString(),
                style: Theme.of(context).textTheme.bodyText2,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: InkWell(
              onTap: unit == Unit.SECS && goals.length > setIndex
                  ? () {
                      showTimer(goals[setIndex]);
                    }
                  : null,
              child: Text(
                goals.length <= setIndex ? "-" : goals[setIndex].toString(),
                style: Theme.of(context).textTheme.headline6.copyWith(
                      color: Colors.green,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: InkWell(
              onTap: () async {
                dynamic result = await CustomDialog.inputDialog(
                  title: "Enter ${unitFullFormValues.reverse[unit]}",
                  context: context,
                  defaultText: data.toString(),
                  textInputType: TextInputType.number,
                );
                if (result != null && result != '')
                  _userWorkoutBloc.add(
                    UpdateSetFromExercise(
                      exerciseIndex,
                      setIndex,
                      int.parse(result),
                    ),
                  );
              },
              child: Center(
                child: Text(
                  unit == Unit.SECS ? "$data 's" : "$data",
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Row(
              children: prev
                  .map(
                    (e) => Expanded(
                      child: Text(
                        "${e ?? '-'}".addFourSpace(),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .color
                                  .withOpacity(0.5),
                              fontWeight: FontWeight.w300,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            flex: 2,
            child: InkWell(
              child: Icon(Icons.remove),
              borderRadius: BorderRadius.circular(100),
              onTap: () async {
                bool result = await CustomDialog.yesNoDialog(
                  title: "Confirm",
                  context: context,
                  description: "Remove Set ${setIndex + 1} ?",
                );
                if (result)
                  _userWorkoutBloc
                      .add(RemoveSetFromExercise(exerciseIndex, setIndex));
              },
            ),
          ),
        ],
      ),
    );
  }
}
