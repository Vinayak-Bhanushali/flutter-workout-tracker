part of 'user_workout_bloc.dart';

abstract class UserWorkoutEvent extends Equatable {
  const UserWorkoutEvent();

  @override
  List<Object> get props => [];
}

class InitalizeUserWorkout extends UserWorkoutEvent {
  final Workout workout;

  InitalizeUserWorkout(this.workout);
}

class DeleteUserWorkout extends UserWorkoutEvent {}

class AddExerciseToUserWorkout extends UserWorkoutEvent {
  final int exerciseId;
  AddExerciseToUserWorkout(this.exerciseId);
  @override
  List<Object> get props => [exerciseId];
}

class RemoveExerciseFromUserWorkout extends UserWorkoutEvent {
  final int exerciseId;
  RemoveExerciseFromUserWorkout(this.exerciseId);
  @override
  List<Object> get props => [exerciseId];
}

class AddSetToExercise extends UserWorkoutEvent {
  final int exerciseIndex;
  final int data;
  AddSetToExercise(this.exerciseIndex, this.data);
  @override
  List<Object> get props => [exerciseIndex, data];
}

class UpdateSetFromExercise extends UserWorkoutEvent {
  final int exerciseIndex;
  final int setIndex;
  final int data;
  UpdateSetFromExercise(this.exerciseIndex, this.setIndex, this.data);
  @override
  List<Object> get props => [exerciseIndex, setIndex, data];
}

class RemoveSetFromExercise extends UserWorkoutEvent {
  final int exerciseIndex;
  final int setIndex;

  RemoveSetFromExercise(this.exerciseIndex, this.setIndex);
  @override
  List<Object> get props => [exerciseIndex, setIndex];
}

class StopWorkout extends UserWorkoutEvent {}

class FinishWorkoutAndUpdateGoals extends UserWorkoutEvent {
  final Set<Exercise> updatedExercises;

  FinishWorkoutAndUpdateGoals(this.updatedExercises);
  @override
  List<Object> get props => [updatedExercises];
}

class LoadUserWorkoutMonthWise extends UserWorkoutEvent {
  final DateTime startDate;
  final DateTime endDate;

  LoadUserWorkoutMonthWise(this.startDate, this.endDate);
  @override
  List<Object> get props => [startDate, endDate];
}

class LoadDetailUserWorkout extends UserWorkoutEvent {
  final UserWorkout userWorkout;

  LoadDetailUserWorkout(this.userWorkout);
}

class LoadUserWorkoutExerciseWise extends UserWorkoutEvent {
  final int exerciseId;
  final DateTime startDate;
  final DateTime endDate;
  LoadUserWorkoutExerciseWise(this.exerciseId, this.startDate, this.endDate);
}
