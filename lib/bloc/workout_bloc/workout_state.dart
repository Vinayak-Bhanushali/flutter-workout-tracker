part of 'workout_bloc.dart';

abstract class WorkoutState extends Equatable {
  const WorkoutState();
}

class WorkoutLoading extends WorkoutState {
  @override
  List<Object> get props => [];
}

class WorkoutLoaded extends WorkoutState {
  final List<Workout> workouts;

  WorkoutLoaded(this.workouts);

  @override
  List<Object> get props => workouts;
}
