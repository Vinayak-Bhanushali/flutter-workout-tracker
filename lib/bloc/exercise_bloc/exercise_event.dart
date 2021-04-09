part of 'exercise_bloc.dart';

abstract class ExerciseEvent extends Equatable {
  const ExerciseEvent();

  @override
  List<Object> get props => [];
}

class LoadExercises extends ExerciseEvent {
  final Workout workout;
  LoadExercises({this.workout});
}

class LoadExercisesForUserWorkout extends ExerciseEvent {
  final Workout workout;
  LoadExercisesForUserWorkout({this.workout});
}

class InsertExercise extends ExerciseEvent {
  final Exercise exercise;
  final Workout workout;

  InsertExercise(this.exercise, this.workout);
}

class UpdateExercise extends ExerciseEvent {
  final Exercise exercise;
  final Workout workout;

  UpdateExercise(this.exercise, this.workout);
}

class DeleteExercise extends ExerciseEvent {
  final Exercise exercise;
  final Workout workout;

  DeleteExercise(this.exercise, this.workout);
}
