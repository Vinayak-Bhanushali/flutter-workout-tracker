import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_tracker/bloc/exercise_bloc/exercise_bloc.dart';
import 'package:workout_tracker/bloc/user_workout_bloc/user_workout_bloc.dart';
import 'package:workout_tracker/models/exercise.dart';
import 'package:workout_tracker/ui/screens/homescreen/statistics/statistic_card.dart';
import 'package:workout_tracker/uitilities/date_formatter.dart';
import 'package:workout_tracker/uitilities/route_generator.dart';
import 'package:workout_tracker/uitilities/custom_extensions.dart';

class StatisticsView extends StatefulWidget {
  final int totalWorkouts;
  final DateTime startDate;
  final DateTime endDate;

  const StatisticsView({
    Key key,
    @required this.startDate,
    @required this.endDate,
    @required this.totalWorkouts,
  }) : super(key: key);
  @override
  _StatisticsViewState createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  ExerciseBloc _exerciseBloc;

  @override
  void initState() {
    super.initState();
    _exerciseBloc = BlocProvider.of<ExerciseBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseBloc, ExerciseState>(
      cubit: _exerciseBloc,
      builder: (context, ExerciseState exerciseState) {
        if (exerciseState is ExerciseLoaded) {
          List<Exercise> mainExercises = [];
          List<Exercise> dailyExercises = [];
          for (var exercise in exerciseState.exercises) {
            if (exercise.dailyExercise)
              dailyExercises.add(exercise);
            else
              mainExercises.add(exercise);
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text("Statistics"),
              centerTitle: true,
              actions: [
                FlatButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(RouteGenerator.timeline),
                  child: const Icon(
                    Icons.timeline,
                    color: Colors.white,
                  ),
                )
              ],
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            children: [
                              Text(
                                "${widget.totalWorkouts} ",
                                style: Theme.of(context).textTheme.headline3,
                              ),
                              Text(
                                "${'workout'.isMultiple(widget.totalWorkouts)} this ${DateFormatter.monthText.format(widget.startDate)}",
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          Expanded(child: const Divider()),
                          const SizedBox(width: 10),
                          Text(
                            "Main Exercises",
                            style: Theme.of(context).textTheme.caption,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: const Divider()),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: GridView.count(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          crossAxisCount: 2,
                          children: mainExercises
                              .map(
                                (exercise) => BlocProvider(
                                  create: (context) => UserWorkoutBloc(),
                                  child: StatisticCard(
                                    exercise: exercise,
                                    startDate: widget.startDate,
                                    endDate: widget.endDate,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          Expanded(child: const Divider()),
                          const SizedBox(width: 10),
                          Text(
                            "Daily Exercises",
                            style: Theme.of(context).textTheme.caption,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: const Divider()),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: GridView.count(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          crossAxisCount: 1,
                          children: dailyExercises
                              .map(
                                (exercise) => BlocProvider(
                                  create: (context) => UserWorkoutBloc(),
                                  child: StatisticCard(
                                    exercise: exercise,
                                    startDate: widget.startDate,
                                    endDate: widget.endDate,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
