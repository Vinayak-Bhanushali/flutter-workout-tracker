import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:workout_tracker/datasources/local/sembast_database/daos/exercise_dao.dart';
import 'package:workout_tracker/models/exercise.dart';
import 'package:workout_tracker/models/workout.dart';

part 'exercise_event.dart';
part 'exercise_state.dart';

class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  ExerciseBloc() : super(ExerciseLoading());
  final ExerciseDao _exerciseDao = ExerciseDao();

  @override
  Stream<ExerciseState> mapEventToState(
    ExerciseEvent event,
  ) async* {
    if (event is LoadExercises) {
      yield ExerciseLoading();
      yield* _reloadExercises(event.workout);
    } else if (event is InsertExercise) {
      await _exerciseDao.insert(event.exercise);
      yield* _reloadExercises(event.workout);
    } else if (event is UpdateExercise) {
      await _exerciseDao.update(event.exercise);
      yield* _reloadExercises(event.workout);
    } else if (event is DeleteExercise) {
      await _exerciseDao.delete(event.exercise);
      yield* _reloadExercises(event.workout);
    } else if (event is LoadExercisesForUserWorkout) {
      final List<Exercise> workoutExercises = event.workout == null
          // All exercises
          ? await _exerciseDao.getAllSortedByName()
          // Exercises of specified workout
          : await _exerciseDao.getAllByWorkout(event.workout);

      final List<Exercise> otherExercises = event.workout == null
          ? []
          // All exercises except specified workout
          : await _exerciseDao.getAllByWorkout(
              event.workout,
              inverse: true,
            );
      yield (ExerciseLoadedForUserWorkout(
        workoutExercises,
        otherExercises,
      ));
    }
  }

  Stream<ExerciseState> _reloadExercises(Workout workout) async* {
    final exercises = workout == null
        ? await _exerciseDao.getAllSortedByName()
        : await _exerciseDao.getAllByWorkout(workout);
    yield ExerciseLoaded(exercises);
  }
}
