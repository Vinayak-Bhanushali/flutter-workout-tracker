part of 'exercise_bloc.dart';

abstract class ExerciseState extends Equatable {
  const ExerciseState();

  @override
  List<Object> get props => [];
}

class ExerciseLoading extends ExerciseState {
  @override
  List<Object> get props => [];
}

class ExerciseLoaded extends ExerciseState {
  final List<Exercise> exercises;

  ExerciseLoaded(this.exercises);

  @override
  List<Object> get props => exercises;
}

class ExerciseLoadedForUserWorkout extends ExerciseState {
  final List<Exercise> workoutExercises;
  final List<Exercise> otherExercises;

  ExerciseLoadedForUserWorkout(this.workoutExercises, this.otherExercises);

  @override
  List<Object> get props => [workoutExercises, otherExercises];
}
