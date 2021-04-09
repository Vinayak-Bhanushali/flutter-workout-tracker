import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sembast/sembast.dart';
import 'package:workout_tracker/datasources/local/sembast_database/app_database.dart';
import 'package:workout_tracker/datasources/local/sembast_database/daos/exercise_dao.dart';
import 'package:workout_tracker/datasources/local/sembast_database/daos/workout_dao.dart';
import 'package:workout_tracker/models/app_data.dart';
import 'package:workout_tracker/uitilities/config_notifications.dart';

part 'app_data_event.dart';
part 'app_data_state.dart';

class AppDataBloc extends Bloc<AppDataEvent, AppDataState> {
  AppDataBloc() : super(AppDataLoading());
  final _store = intMapStoreFactory.store("App_Data");

  @override
  Stream<AppDataState> mapEventToState(
    AppDataEvent event,
  ) async* {
    if (event is AppDataLoad) {
      AppData appData = await _getAppDataFromDb();
      if (appData == null) {
        appData = await handleFirstRun();
      }
      yield AppDataLoaded(appData);
    } else if (event is AppDataUpdate) {
      yield AppDataLoaded(event.appData);
      updateAppDataToDb(event.appData);
    } else if (event is UpdateRemainderData) {
      if (!event.remainderSettings.enabled) {
        ConfigNotifications.instance.cancelAll();
      } else {
        var endDate = await ConfigNotifications.instance.scheduleRemainders(
          event.remainderSettings.selectedDays,
          event.remainderSettings.time,
        );
        event.remainderSettings.notificationsScheduled = endDate;
      }
    }
  }

  Future<AppData> _getAppDataFromDb() async {
    final snapshot = await _store.findFirst(
      await AppDatabase.instance.database,
    );
    if (snapshot == null) return null;
    return AppData.fromJson(snapshot.value);
  }

  Future updateAppDataToDb(AppData appData) async {
    return await _store.update(
      await AppDatabase.instance.database,
      appData.toJson(),
    );
  }

  Future<AppData> handleFirstRun() async {
    AppData _appData = AppData(
      noOfRuns: 0,
      userData: UserData(
        name: null,
        age: null,
        height: null,
        weight: null,
      ),
      remainderSettings: RemainderSettings(
        enabled: false,
        selectedDays: {},
        time: TimeOfDay.now(),
        notificationsScheduled: DateTime.now(),
      ),
    );
    final _workoutStore =
        intMapStoreFactory.store(WorkoutDao.WORKOUT_STORE_NAME);
    final _exerciseStore =
        intMapStoreFactory.store(ExerciseDao.EXERCISE_STORE_NAME);
    // prepopulate
    String workoutData = await rootBundle
        .loadString("assets/data/database_initial/workouts.json");
    List workouts = jsonDecode(workoutData);
    for (var element in workouts) {
      await _workoutStore.add(await AppDatabase.instance.database, element);
    }
    // await workouts.forEach((element) async {
    //   await _workoutStore.add(await AppDatabase.instance.database, element);
    // });
    String exerciseData = await rootBundle
        .loadString("assets/data/database_initial/exercises.json");
    List exercises = jsonDecode(exerciseData);
    for (var element in exercises) {
      await _exerciseStore.add(await AppDatabase.instance.database, element);
    }
    // await exercises.forEach((element) async {
    //   await _exerciseStore.add(await AppDatabase.instance.database, element);
    // });
    await _store.add(
      await AppDatabase.instance.database,
      _appData.toJson(),
    );
    return _appData;
  }
}
