import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_tracker/bloc/exercise_bloc/exercise_bloc.dart';
import 'package:workout_tracker/bloc/timeline_bloc/timeline_bloc.dart';
import 'package:workout_tracker/bloc/user_workout_bloc/user_workout_bloc.dart';
import 'package:workout_tracker/bloc/workout_bloc/workout_bloc.dart';
import 'package:workout_tracker/models/user_workout.dart';
import 'package:workout_tracker/ui/screens/homescreen/home_screen.dart';
import 'package:workout_tracker/ui/screens/homescreen/statistics/statistics_view.dart';
import 'package:workout_tracker/ui/screens/homescreen/timeline/timeline_view.dart';
import 'package:workout_tracker/ui/screens/settings/manage_exercise.dart';
import 'package:workout_tracker/ui/screens/settings/settings.dart';
import 'package:workout_tracker/ui/screens/workout/detail_workout.dart';
import 'package:workout_tracker/ui/screens/workout/finish_workout.dart';
import 'package:workout_tracker/ui/screens/workout/initialize_workout.dart';

class RouteGenerator {
  static const String home = "/";
  static const String statistics = "statistics";
  static const String timeline = "timeline";

  static const String initalizeWorkout = "initalizeWorkout";
  static const String detailWorkout = "detailWorkout";
  static const String repeatWorkout = "repeatWorkout";
  static const String finishWorkout = "finishWorkout";

  static const String settingsHome = "settingsHome";
  static const String manageExercise = "manageExercise";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider<UserWorkoutBloc>(
                create: (context) => UserWorkoutBloc(),
              ),
              BlocProvider<ExerciseBloc>(
                create: (context) => ExerciseBloc(),
              ),
            ],
            child: HomeScreen(),
          ),
        );
      case statistics:
        Map arguments = settings.arguments as Map;

        return MaterialPageRoute(
          settings: settings,
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider<UserWorkoutBloc>(
                create: (context) => UserWorkoutBloc(),
              ),
              BlocProvider<ExerciseBloc>.value(
                value: arguments['_exerciseBloc'],
              ),
            ],
            child: StatisticsView(
              startDate: arguments['_startDate'],
              endDate: arguments['_endDate'],
              totalWorkouts: arguments['_totalWorkouts'],
            ),
          ),
        );
      case timeline:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => BlocProvider(
            create: (context) => TimelineBloc(),
            child: TimeLineView(),
          ),
        );
      case initalizeWorkout:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => UserWorkoutBloc(),
              ),
              BlocProvider<WorkoutBloc>(
                create: (context) => WorkoutBloc(),
              ),
              BlocProvider<ExerciseBloc>(
                create: (context) => ExerciseBloc(),
              ),
            ],
            child: InitalizeWorkout(
              quote: settings.arguments,
            ),
          ),
        );
      case repeatWorkout:
        final userWorkout = settings.arguments as UserWorkout;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => UserWorkoutBloc(userWorkout: userWorkout),
              ),
              BlocProvider(
                create: (context) => ExerciseBloc(),
              ),
            ],
            child: DetailWorkout(
              workout: userWorkout.workout,
            ),
          ),
        );
      case detailWorkout:
        Map arguments = settings.arguments as Map;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => UserWorkoutBloc(),
              ),
              BlocProvider.value(
                value: arguments['_exerciseBloc'] as ExerciseBloc,
              ),
            ],
            child: DetailWorkout(
              workout: arguments['workout'],
            ),
          ),
        );
      case finishWorkout:
        Map arguments = settings.arguments as Map;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider<UserWorkoutBloc>.value(
                value: arguments['_userWorkoutBloc'] as UserWorkoutBloc,
              ),
              BlocProvider.value(
                value: arguments['_exerciseBloc'] as ExerciseBloc,
              ),
              BlocProvider(
                create: (context) => TimelineBloc(),
              )
            ],
            child: FinishWorkout(
              timeline: arguments['_timeline'],
            ),
          ),
        );
      case settingsHome:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => BlocProvider<WorkoutBloc>(
            create: (context) => WorkoutBloc(),
            child: Settings(),
          ),
        );
      case manageExercise:
        Map arguments = settings.arguments as Map;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => BlocProvider<ExerciseBloc>(
            create: (context) => ExerciseBloc(),
            child: ManageExercise(
              selectedWorkout: arguments['selectedWorkout'],
              allWorkouts: arguments['allWorkouts'],
            ),
          ),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => Container(
            child: const Text("Something went wrong :("),
          ),
        );
    }
  }
}
