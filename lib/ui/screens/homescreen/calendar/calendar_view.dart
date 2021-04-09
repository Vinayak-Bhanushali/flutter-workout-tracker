import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:workout_tracker/bloc/exercise_bloc/exercise_bloc.dart';
import 'package:workout_tracker/bloc/user_workout_bloc/user_workout_bloc.dart';
import 'package:workout_tracker/models/exercise.dart';
import 'package:workout_tracker/models/user_workout.dart';
import 'package:workout_tracker/ui/screens/homescreen/calendar/workout_alert.dart';
import 'package:workout_tracker/ui/widgets/custom_dialogue.dart';
import 'package:workout_tracker/ui/widgets/hero_dialog_route.dart';
import 'package:workout_tracker/uitilities/custom_extensions.dart';
import 'package:workout_tracker/uitilities/date_formatter.dart';
import 'package:workout_tracker/uitilities/route_generator.dart';

class CalendarView extends StatefulWidget {
  final Function(UserWorkout userWorkout) repeatWorkout;
  CalendarView({Key key, @required this.repeatWorkout}) : super(key: key);

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  UserWorkoutBloc _userWorkoutBloc;
  ExerciseBloc _exerciseBloc;
  final today = DateTime.now();
  DateTime _startDate;
  DateTime _endDate;
  DateTime _selectedDate;
  CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime(today.year, today.month, 1);
    _endDate = DateTime(today.year, today.month, today.day, 23, 59, 59);
    _selectedDate = DateTime(
      today.year,
      today.month,
      today.day,
    );
    _userWorkoutBloc = BlocProvider.of<UserWorkoutBloc>(context);
    _exerciseBloc = BlocProvider.of<ExerciseBloc>(context);
    _exerciseBloc.add(LoadExercises());
    _userWorkoutBloc.add(LoadUserWorkoutMonthWise(_startDate, _endDate));
    _calendarController = CalendarController();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseBloc, ExerciseState>(
      cubit: _exerciseBloc,
      buildWhen: (previous, current) => true,
      builder: (context, ExerciseState exerciseState) {
        if (exerciseState is ExerciseLoaded) {
          return BlocBuilder<UserWorkoutBloc, UserWorkoutState>(
            cubit: _userWorkoutBloc,
            buildWhen: (previous, current) => true,
            builder: (context, state) {
              if (state is UserWorkoutLoaded) {
                List<Widget> workoutCardList = state.events[_selectedDate] ==
                        null
                    ? []
                    : List.generate(
                        state.events[_selectedDate].length,
                        (index) => workoutCard(
                            state.events[_selectedDate][index], exerciseState),
                      );
                return Stack(
                  children: [
                    TableCalendar(
                      calendarController: _calendarController,
                      onDaySelected: (day, events, holidays) {
                        _selectedDate = DateTime(
                          day.year,
                          day.month,
                          day.day,
                        );
                        setState(() {});
                      },
                      onVisibleDaysChanged: (first, last, format) {
                        _startDate = DateTime(
                          first.year,
                          first.month,
                          first.day,
                        );
                        _endDate = DateTime(
                          last.year,
                          last.month,
                          last.day,
                          23,
                          59,
                          59,
                        );
                        _userWorkoutBloc.add(
                          LoadUserWorkoutMonthWise(_startDate, _endDate),
                        );
                      },
                      events: state.events,
                      initialCalendarFormat: CalendarFormat.month,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      initialSelectedDay: _selectedDate,
                      endDay: today,
                      availableGestures: AvailableGestures.horizontalSwipe,
                      calendarStyle: CalendarStyle(
                        weekdayStyle: Theme.of(context).textTheme.bodyText2,
                        weekendStyle: Theme.of(context).textTheme.bodyText2,
                        todayStyle: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(decoration: TextDecoration.underline),
                        todayColor: Colors.transparent,
                        markersColor: Colors.green,
                        markersMaxAmount: 1,
                        outsideDaysVisible: false,
                        outsideWeekendStyle: CalendarStyle().outsideStyle,
                      ),
                      headerStyle: HeaderStyle(
                        centerHeaderTitle: true,
                        formatButtonVisible: false,
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                        ),
                        titleExtraWidget: IconButton(
                          icon: Icon(Icons.bar_chart),
                          onPressed: state.events.isEmpty
                              ? null
                              : () {
                                  Navigator.of(context).pushNamed(
                                      RouteGenerator.statistics,
                                      arguments: {
                                        '_exerciseBloc': _exerciseBloc,
                                        '_startDate': _startDate,
                                        '_endDate': _endDate,
                                        '_totalWorkouts':
                                            state.events.values.length,
                                      });
                                },
                        ),
                      ),
                      builders: CalendarBuilders(
                        dowWeekdayBuilder: (context, weekday) => Text(
                          weekday,
                          style: Theme.of(context).textTheme.caption,
                          textAlign: TextAlign.center,
                        ),
                        dowWeekendBuilder: (context, weekday) => Text(
                          weekday,
                          style: Theme.of(context).textTheme.caption,
                          textAlign: TextAlign.center,
                        ),
                        selectedDayBuilder: (context, date, events) =>
                            Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).accentColor,
                          ),
                          child: Center(
                            child: Text(
                              date.day.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    DraggableScrollableSheet(
                      key: UniqueKey(),
                      initialChildSize: 0.35,
                      minChildSize: 0.35,
                      builder: (context, scrollController) => Card(
                        color: Theme.of(context).canvasColor,
                        elevation: 6,
                        child: workoutCardList.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Card(
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      width: double.maxFinite,
                                      child: Text(
                                        "No workouts found for this day",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : ListView(
                                controller: scrollController,
                                shrinkWrap: true,
                                children: workoutCardList,
                              ),
                      ),
                    ),
                  ],
                );
              } else
                return Container();
            },
          );
        } else
          return Container();
      },
    );
  }

  Widget workoutCard(UserWorkout userWorkout, ExerciseLoaded exerciseLoaded) {
    userWorkout.exerciseData.sort((a, b) {
      Exercise exerciseA;

      int exerciseIndexA = exerciseLoaded.exercises
          .indexWhere((element) => element.id == a.exerciseId);
      if (exerciseIndexA >= 0) {
        exerciseA = exerciseLoaded.exercises[exerciseIndexA];
      }
      if (exerciseA.dailyExercise)
        return 1;
      else
        return -1;
    });
    String duration = userWorkout.endTime
            ?.difference(userWorkout.startTime)
            ?.inMinutes
            .toString() ??
        "";
    if (duration.isNotEmpty) duration += " mins";
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: userWorkout.exerciseData.length < 1
            ? null
            : () {
                Navigator.push(
                  context,
                  HeroDialogRoute(
                    context: context,
                    builder: (BuildContext context) {
                      return MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (context) => UserWorkoutBloc(),
                          ),
                          BlocProvider.value(value: _exerciseBloc)
                        ],
                        child: WorkoutAlert(
                          userWorkout: userWorkout,
                        ),
                      );
                    },
                  ),
                );
              },
        child: Column(
          children: [
            Hero(
              tag: userWorkout.id,
              child: Container(
                color: Theme.of(context).accentColor,
                width: double.maxFinite,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        userWorkout?.workout?.name ?? "All",
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(color: Colors.white),
                      ),
                    ),
                    Material(
                      color: Theme.of(context).accentColor,
                      child: InkWell(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(
                            Icons.repeat,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () async {
                          bool result = await CustomDialog.yesNoDialog(
                            title: "Repeat this workout?",
                            description:
                                "All exercises of this workout will be added to your current workout.",
                            context: context,
                          );
                          if (result) {
                            UserWorkout newUserWorkout =
                                UserWorkout.fromJson(userWorkout.toJson());
                            newUserWorkout.id = null;
                            newUserWorkout.endTime = null;
                            newUserWorkout.startTime = DateTime.now();
                            newUserWorkout.exerciseData.forEach((element) {
                              element.setData = List.filled(
                                element.setData.length,
                                0,
                                growable: true,
                              );
                            });
                            widget.repeatWorkout(newUserWorkout);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
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
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      children: userWorkout.exerciseData.map(
                        (e) {
                          Exercise exercise;
                          int exerciseIndex = exerciseLoaded.exercises
                              .indexWhere(
                                  (element) => element.id == e.exerciseId);
                          if (exerciseIndex >= 0) {
                            exercise = exerciseLoaded.exercises[exerciseIndex];
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    exercise.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                  ),
                                ),
                                const Spacer(),
                                Expanded(
                                  flex: 5,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: e.setData
                                          .map((e) => Text(
                                                e
                                                    .toString()
                                                    .padLeft(2, "0")
                                                    .addFourSpace(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2,
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  Text(
                    MediaQuery.of(context).alwaysUse24HourFormat
                        ? "${DateFormatter.time24hours.format(userWorkout.startTime)}"
                        : "${DateFormatter.time12hours.format(userWorkout.startTime)}",
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
