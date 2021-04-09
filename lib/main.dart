import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_tracker/bloc/app_data_bloc/app_data_bloc.dart';
import 'package:workout_tracker/models/enums.dart';
import 'package:workout_tracker/uitilities/config_notifications.dart';
import 'package:workout_tracker/uitilities/route_generator.dart';
import 'package:workout_tracker/uitilities/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppDataBloc>(
      create: (context) => AppDataBloc(),
      child: WorkoutTracker(),
    );
  }
}

class WorkoutTracker extends StatelessWidget {
  ThemeMode themeMode(AppTheme appTheme) {
    switch (appTheme) {
      case AppTheme.System:
        return ThemeMode.system;
      case AppTheme.Light:
        return ThemeMode.light;
      case AppTheme.Dark:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    AppDataBloc _appDataBloc = BlocProvider.of<AppDataBloc>(context);
    _appDataBloc.add(AppDataLoad());
    return BlocBuilder<AppDataBloc, AppDataState>(
      cubit: _appDataBloc,
      builder: (context, state) {
        if (state is AppDataLoaded) {
          ConfigNotifications.instance;
          if (state.appData.remainderSettings.enabled)
            ConfigNotifications.instance
                .updateNotificationSchedules(
              state.appData.remainderSettings.notificationsScheduled,
              state.appData.remainderSettings.selectedDays,
              state.appData.remainderSettings.time,
            )
                .then((value) {
              if (value != null) {
                state.appData.remainderSettings.notificationsScheduled = value;
                _appDataBloc.add(
                  AppDataUpdate(state.appData),
                );
              }
            });

          return MaterialApp(
            title: 'Workout Tracker',
            theme: Themes.lightTheme,
            darkTheme: Themes.darkTheme,
            themeMode: themeMode(state.appData.appTheme),
            onGenerateRoute: (settings) =>
                RouteGenerator.generateRoute(settings),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
