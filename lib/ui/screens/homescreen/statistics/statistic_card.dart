import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_tracker/bloc/user_workout_bloc/user_workout_bloc.dart';
import 'package:workout_tracker/models/exercise.dart';
import 'package:workout_tracker/ui/screens/homescreen/statistics/statistic_alert.dart';
import 'package:workout_tracker/ui/widgets/hero_dialog_route.dart';
import 'package:workout_tracker/uitilities/date_formatter.dart';

class StatisticCard extends StatefulWidget {
  final Exercise exercise;
  final DateTime startDate;
  final DateTime endDate;

  const StatisticCard(
      {Key key,
      @required this.exercise,
      @required this.startDate,
      @required this.endDate})
      : super(key: key);
  @override
  _StatisticCardState createState() => _StatisticCardState();
}

class _StatisticCardState extends State<StatisticCard> {
  UserWorkoutBloc _userWorkoutBloc;

  @override
  void initState() {
    super.initState();
    _userWorkoutBloc = BlocProvider.of<UserWorkoutBloc>(context);
    _userWorkoutBloc.add(LoadUserWorkoutExerciseWise(
        widget.exercise.id, widget.startDate, widget.endDate));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserWorkoutBloc, UserWorkoutState>(
      cubit: _userWorkoutBloc,
      builder: (context, state) {
        if (state is ExerciseWiseUserWorkout) {
          List<int> average = [];
          List<int> counter = [];
          for (var data in state.data) {
            for (var setData in data.values) {
              for (var i = 0; i < setData.length; i++) {
                if (counter.length > i) {
                  counter[i]++;
                  //  (counter[i] + setData[i]) ~/ 2;
                } else {
                  counter.add(1);
                }
                if (average.length > i) {
                  average[i] =
                      average[i] + ((setData[i] - average[i]) ~/ counter[i]);
                  //  (average[i] + setData[i]) ~/ 2;
                } else {
                  average.add(setData[i]);
                }
              }
            }
          }
          return Card(
            child: InkWell(
              onTap: state.data.length <= 1
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        HeroDialogRoute(
                          context: context,
                          builder: (BuildContext context) {
                            return StatisticsAlert(
                              month: DateFormatter.monthTextAndYear.format(
                                widget.startDate,
                              ),
                              exercise: widget.exercise,
                              data: state.data,
                            );
                          },
                        ),
                      );
                    },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Hero(
                        tag: widget.exercise.id,
                        child: Text(
                          widget.exercise.name,
                          style: Theme.of(context).textTheme.subtitle1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: (average.length < 1)
                        ? Text(
                            "No Data ",
                            style: Theme.of(context).textTheme.caption,
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                average.length,
                                (index) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        widget.exercise.goals.length > index
                                            ? widget.exercise.goals[index]
                                                .toString()
                                            : "-",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                      Text(
                                        average[index].toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                  )
                ],
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
