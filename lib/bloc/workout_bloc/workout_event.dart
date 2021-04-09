part of 'workout_bloc.dart';

abstract class WorkoutEvent extends Equatable {
  const WorkoutEvent();

  @override
  List<Object> get props => [];
}

class LoadWorkouts extends WorkoutEvent {}

class InsertWorkout extends WorkoutEvent {
  final Workout workout;
  InsertWorkout(this.workout);
}

class UpdateWorkout extends WorkoutEvent {
  final Workout workout;
  UpdateWorkout(this.workout);
}

class DeleteWorkout extends WorkoutEvent {
  final Workout workout;
  DeleteWorkout(this.workout);
}
