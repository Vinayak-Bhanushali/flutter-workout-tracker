import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_tracker/bloc/exercise_bloc/exercise_bloc.dart';
import 'package:workout_tracker/bloc/user_workout_bloc/user_workout_bloc.dart';
import 'package:workout_tracker/bloc/workout_bloc/workout_bloc.dart';
import 'package:workout_tracker/models/quote.dart';
import 'package:workout_tracker/ui/screens/workout/exercise_list.dart';
import 'package:workout_tracker/uitilities/date_formatter.dart';
import 'package:workout_tracker/uitilities/route_generator.dart';

class InitalizeWorkout extends StatefulWidget {
  final Quote quote;

  const InitalizeWorkout({Key key, this.quote}) : super(key: key);
  @override
  _InitalizeWorkoutState createState() => _InitalizeWorkoutState();
}

class _InitalizeWorkoutState extends State<InitalizeWorkout> {
  WorkoutBloc _workoutBloc;
  ExerciseBloc _exerciseBloc;
  UserWorkoutBloc _userWorkoutBloc;
  final today = DateTime.now();

  int _selectedWorkoutIndex;
  @override
  void initState() {
    super.initState();
    _userWorkoutBloc = BlocProvider.of<UserWorkoutBloc>(context);
    _userWorkoutBloc.add(
      LoadUserWorkoutMonthWise(
        today.subtract(
          Duration(days: 15),
        ),
        today,
      ),
    );
    _exerciseBloc = BlocProvider.of<ExerciseBloc>(context);
    _workoutBloc = BlocProvider.of<WorkoutBloc>(context);
    _workoutBloc.add(LoadWorkouts());
    _selectedWorkoutIndex = 1;
  }

  final DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserWorkoutBloc, UserWorkoutState>(
        cubit: _userWorkoutBloc,
        builder: (context, UserWorkoutState userWorkoutState) {
          Set<int> currentDayPreferedWorkout = {};
          if (userWorkoutState is UserWorkoutLoaded) {
            userWorkoutState.events.values.forEach((element) {
              for (var userWorkout in element) {
                if (userWorkout.startTime.weekday == today.weekday) {
                  currentDayPreferedWorkout.add(userWorkout.workout.id);
                }
              }
            });
            return BlocBuilder<WorkoutBloc, WorkoutState>(
              cubit: _workoutBloc,
              builder: (context, state) {
                if (state is WorkoutLoaded) {
                  state.workouts.sort((a, b) {
                    if (currentDayPreferedWorkout.contains(a.id))
                      return -1;
                    else
                      return 1;
                  });
                  return Scaffold(
                    body: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            Flexible(
                              flex: 2,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.timer),
                                      const SizedBox(width: 10),
                                      Text(
                                        MediaQuery.of(context)
                                                .alwaysUse24HourFormat
                                            ? "${DateFormatter.time24hours.format(now)}"
                                            : "${DateFormatter.time12hours.format(now)}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2,
                                      ),
                                    ],
                                  ),
                                  if (widget.quote != null) ...[
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Flexible(
                                      child: Text(
                                        "“ ${widget.quote.quoteText} ”",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Flexible(
                                      child: Text(
                                        "~ ${widget.quote.quoteAuthor ?? ''}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20.0),
                              child: Divider(
                                indent: 40,
                                endIndent: 40,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  Text(
                                    "Select Workout",
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  CarouselSlider(
                                    items: List.generate(
                                      state.workouts.length + 1,
                                      (index) => workoutCard(
                                        index,
                                        state,
                                        context,
                                      ),
                                    ),
                                    options: CarouselOptions(
                                      initialPage: _selectedWorkoutIndex,
                                      enableInfiniteScroll: true,
                                      enlargeCenterPage: true,
                                      viewportFraction: 0.6,
                                      aspectRatio: 3 / 2,
                                      onPageChanged: (index, reason) {
                                        _selectedWorkoutIndex = index;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    bottomNavigationBar: Material(
                      color: Theme.of(context).accentColor,
                      elevation: 4,
                      child: InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "START",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .copyWith(color: Colors.white),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed(
                            RouteGenerator.detailWorkout,
                            arguments: {
                              '_exerciseBloc': _exerciseBloc,
                              'workout': _selectedWorkoutIndex == 0
                                  ? null
                                  : state.workouts[_selectedWorkoutIndex - 1]
                            },
                          );
                        },
                      ),
                    ),
                  );
                } else {
                  return Scaffold();
                }
              },
            );
          } else
            return Container();
        });
  }

  Container workoutCard(int index, WorkoutLoaded state, BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: index == 0
            ? Theme.of(context).accentColor
            : index % 2 == 0
                ? Colors.blue
                : Colors.red,
      ),
      child: Column(
        children: [
          Text(
            index == 0 ? "All" : state.workouts[index - 1].name,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(color: Colors.white),
          ),
          const SizedBox(
            height: 10,
          ),
          Flexible(
            child: BlocProvider(
              create: (context) => ExerciseBloc(),
              child: ExerciseList(
                workout: index == 0 ? null : state.workouts[index - 1],
              ),
            ),
          )
        ],
      ),
    );
  }
}
