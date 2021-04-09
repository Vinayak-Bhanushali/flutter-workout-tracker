import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:workout_tracker/datasources/local/sembast_database/daos/exercise_dao.dart';
import 'package:workout_tracker/datasources/local/sembast_database/daos/workout_dao.dart';
import 'package:workout_tracker/models/workout.dart';

part 'workout_event.dart';
part 'workout_state.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  WorkoutBloc() : super(WorkoutLoading());
  final WorkoutDao _workoutDao = WorkoutDao();
  final ExerciseDao _exerciseDao = ExerciseDao();

  @override
  Stream<WorkoutState> mapEventToState(
    WorkoutEvent event,
  ) async* {
    if (event is LoadWorkouts) {
      yield WorkoutLoading();
      yield* _reloadWorkouts();
    } else if (event is InsertWorkout) {
      await _workoutDao.insert(event.workout);
      yield* _reloadWorkouts();
    } else if (event is UpdateWorkout) {
      await _workoutDao.update(event.workout);
      yield* _reloadWorkouts();
    } else if (event is DeleteWorkout) {
      await _workoutDao.delete(event.workout);
      await _exerciseDao.removeWorkoutFromExercises(event.workout);
      yield* _reloadWorkouts();
    }
  }

  Stream<WorkoutState> _reloadWorkouts() async* {
    final workouts = await _workoutDao.getAllSortedByName();
    yield WorkoutLoaded(workouts);
  }
}
