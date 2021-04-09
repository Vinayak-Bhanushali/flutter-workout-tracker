import 'dart:math' show pow;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_tracker/bloc/app_data_bloc/app_data_bloc.dart';
import 'package:workout_tracker/datasources/repositoires/quote_repository.dart';
import 'package:workout_tracker/models/quote.dart';
import 'package:workout_tracker/models/user_workout.dart';
import 'package:workout_tracker/ui/screens/homescreen/calendar/calendar_view.dart';
import 'package:workout_tracker/uitilities/common_functions.dart';
import 'package:workout_tracker/uitilities/route_generator.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Quote quote;

  @override
  void initState() {
    super.initState();
    updateQuote();
  }

  updateQuote() async {
    quote = await QuoteRepository.fetchQuote();
  }

  openSettings() {
    Navigator.of(context).pushNamed(RouteGenerator.settingsHome);
  }

  startWorkout({UserWorkout userWorkout}) async {
    if (userWorkout == null) {
      updateQuote();
      Navigator.of(context).pushNamed(
        RouteGenerator.initalizeWorkout,
        arguments: quote,
      );
    } else {
      Navigator.of(context).pushNamed(
        RouteGenerator.repeatWorkout,
        arguments: userWorkout,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            userData(context),
            Flexible(
              child: CalendarView(
                repeatWorkout: (userWorkout) =>
                    startWorkout(userWorkout: userWorkout),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: startWorkout,
        label: Text("Start Workout"),
        icon: Icon(Icons.accessibility_new),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget userData(BuildContext context) {
    return BlocBuilder<AppDataBloc, AppDataState>(
      cubit: BlocProvider.of<AppDataBloc>(context),
      builder: (context, state) {
        if (state is AppDataLoaded) {
          double bmi;
          if (state.appData.userData.height != null &&
              state.appData.userData.weight != null) {
            bmi = (state.appData.userData.weight) /
                pow((state.appData.userData.height / 100), 2);
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Hero(
                  tag: "UserImage",
                  child: CircleAvatar(
                    child: Icon(Icons.person_outline_rounded),
                  ),
                ),
                Spacer(),
                Expanded(
                  flex: 20,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: state.appData.userData.name == null
                        ? GestureDetector(
                            onTap: openSettings,
                            child: Text(
                              "Click to setup inital data",
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hello, ${state.appData.userData.name} !!!",
                                style: Theme.of(context).textTheme.headline5,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              if (bmi != null)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${bmi.toStringAsFixed(1)}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .copyWith(
                                            color:
                                                CommonFunctions.bmiColor(bmi),
                                          ),
                                    ),
                                    Text(
                                      " bmi",
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                  ],
                                )
                            ],
                          ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: openSettings,
                ),
              ],
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
