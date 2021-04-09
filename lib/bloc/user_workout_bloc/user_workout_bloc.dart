import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:workout_tracker/datasources/local/sembast_database/daos/exercise_dao.dart';
import 'package:workout_tracker/datasources/local/sembast_database/daos/user_workout_dao.dart';
import 'package:workout_tracker/models/exercise.dart';
import 'package:workout_tracker/models/user_workout.dart';
import 'package:workout_tracker/models/workout.dart';

part 'user_workout_event.dart';
part 'user_workout_state.dart';

class UserWorkoutBloc extends Bloc<UserWorkoutEvent, UserWorkoutState> {
  UserWorkoutBloc({this.userWorkout}) : super(UserWorkoutInitial());
  // Dao objects
  final UserWorkoutDao _userWorkoutDao = UserWorkoutDao();
  final ExerciseDao _exerciseDao = ExerciseDao();

  // initalize userworkout will be shared within all events;
  UserWorkout userWorkout;

  // cache previous workout data
  Map<int, List<List<int>>> previousData = {};

  Future<void> addToPreviousData(int exerciseId) async {
    final int maxDataLimit = 3;

    // limit is true if maxDataLimit records of exercises are fetched or fecth returns empty list
    bool limitDone = false;

    // initaial offset
    int offset = 1;

    // max objects in one query
    final int limit = 50;

    previousData[exerciseId] = [];

    while (!limitDone) {
      // fetch workouts in gap of limit
      List<UserWorkout> limitData =
          await _userWorkoutDao.getAllRecentWithLimit(offset, limit);
      // break if no workouts found
      if (limitData.length <= 0) {
        limitDone = true;
      } else {
        for (var userWorkout in limitData) {
          for (var exerciseData in userWorkout.exerciseData) {
            if (exerciseData.exerciseId == exerciseId) {
              previousData[exerciseId].add(exerciseData.setData);
              break;
            }
          }
          if (previousData[exerciseId].length > maxDataLimit) {
            limitDone = true;
            break;
          }
        }
        offset += limit;
      }
    }
  }

  @override
  Stream<UserWorkoutState> mapEventToState(
    UserWorkoutEvent event,
  ) async* {
    if (event is InitalizeUserWorkout) {
      if (userWorkout == null) {
        // new workout
        userWorkout = UserWorkout(
          startTime: DateTime.now(),
          endTime: DateTime.now(),
          exerciseData: [],
        );
        previousData = {};
      }
      userWorkout.workout = event.workout;
      int key = await _userWorkoutDao.insert(userWorkout);
      if (key != null) userWorkout.id = key;

      // repeat previous workout
      for (var element in userWorkout.exerciseData) {
        await addToPreviousData(element.exerciseId);
      }

      yield UserWorkoutActive(
        userWorkout,
        previousData,
      );
    } else if (event is DeleteUserWorkout) {
      _userWorkoutDao.delete(userWorkout);
    } else if (event is AddExerciseToUserWorkout) {
      // add new object to exerciseData with empty SetData

      await addToPreviousData(event.exerciseId);
      await _userWorkoutDao.update(userWorkout);
      if (previousData[event.exerciseId] != null &&
          previousData[event.exerciseId].length > 3) {
        int avgSet = 0;
        // getting no of sets average from last three workouts
        for (var i = 0; i < 3; i++) {
          avgSet += previousData[event.exerciseId].skip(i).first.length;
        }
        avgSet ~/= 3;
        userWorkout.exerciseData.add(
          ExerciseDatum(
            exerciseId: event.exerciseId,
            setData: List.filled(
              avgSet,
              0,
              growable: true,
            ),
          ),
        );
      } else {
        userWorkout.exerciseData.add(
          ExerciseDatum(
            exerciseId: event.exerciseId,
            setData: [0],
          ),
        );
      }
      yield UserWorkoutActive(
        userWorkout,
        previousData,
      );
      // increase frequency of exercise
      _exerciseDao.increaseFrequency(event.exerciseId);
    } else if (event is RemoveExerciseFromUserWorkout) {
      // remove exercise from exerciseData
      userWorkout.exerciseData
          .removeWhere((element) => element.exerciseId == event.exerciseId);
      await _userWorkoutDao.update(userWorkout);
      yield UserWorkoutActive(
        userWorkout,
        previousData,
      );
      // decrease frequency of exercise
      _exerciseDao.decreaseFrequency(event.exerciseId);
    } else if (event is AddSetToExercise) {
      // add data to the setData of exerciseData
      userWorkout.exerciseData[event.exerciseIndex].setData.add(event.data);
      await _userWorkoutDao.update(userWorkout);
      yield UserWorkoutActive(
        userWorkout,
        previousData,
      );
    } else if (event is UpdateSetFromExercise) {
      // update given data to the setData of exerciseData
      userWorkout.exerciseData[event.exerciseIndex].setData[event.setIndex] =
          event.data;
      await _userWorkoutDao.update(userWorkout);
      yield UserWorkoutActive(
        userWorkout,
        previousData,
      );
    } else if (event is RemoveSetFromExercise) {
      userWorkout.exerciseData[event.exerciseIndex].setData
          .removeAt(event.setIndex);
      await _userWorkoutDao.update(userWorkout);
      yield UserWorkoutActive(
        userWorkout,
        previousData,
      );
    } else if (event is StopWorkout) {
      userWorkout.endTime = DateTime.now();
      await _userWorkoutDao.update(userWorkout);
      yield UserWorkoutActive(
        userWorkout,
        previousData,
      );
    } else if (event is FinishWorkoutAndUpdateGoals) {
      for (var exercise in event.updatedExercises) {
        await _exerciseDao.update(exercise);
      }
      yield UserWorkoutFinish();
    } else if (event is LoadUserWorkoutMonthWise) {
      Map<DateTime, List<UserWorkout>> calendarEvent = {};
      List<UserWorkout> workouts = await _userWorkoutDao.getAllWorkoutsinRange(
        event.startDate,
        event.endDate,
      );
      workouts.forEach((userWorkout) {
        DateTime key = DateTime(
          userWorkout.startTime.year,
          userWorkout.startTime.month,
          userWorkout.startTime.day,
        );
        if (calendarEvent[key] == null) {
          calendarEvent[key] = [];
        }
        calendarEvent[key].add(userWorkout);
      });
      yield UserWorkoutLoaded(calendarEvent);
    } else if (event is LoadDetailUserWorkout) {
      Map<int, List<Map<DateTime, List<int>>>> previousData = {};
      for (var exerciseDatum in event.userWorkout.exerciseData) {
        final int maxDataLimit = 7;

        if (previousData[exerciseDatum.exerciseId] == null)
          previousData[exerciseDatum.exerciseId] = [];

        List<UserWorkout> records =
            await _userWorkoutDao.getAllAfter(event.userWorkout, maxDataLimit);

        for (var userWorkout in records) {
          for (var exerciseData in userWorkout.exerciseData) {
            if (exerciseData.exerciseId == exerciseDatum.exerciseId) {
              previousData[exerciseDatum.exerciseId]
                  .add({userWorkout.startTime: exerciseData.setData});
              break;
            }
          }
          if (previousData[exerciseDatum.exerciseId].length > maxDataLimit) {
            break;
          }
        }
      }
      yield (DetailUserWorkout(previousData));
    } else if (event is LoadUserWorkoutExerciseWise) {
      List<Map<DateTime, List<int>>> data = [];
      List<UserWorkout> records = await _userWorkoutDao.getAllWorkoutsinRange(
          event.startDate, event.endDate);
      for (var userWorkout in records) {
        for (var exerciseData in userWorkout.exerciseData) {
          if (exerciseData.exerciseId == event.exerciseId) {
            data.add({userWorkout.startTime: exerciseData.setData});
            break;
          }
        }
      }
      yield (ExerciseWiseUserWorkout(data));
    }
  }
}
