part of 'user_workout_bloc.dart';

abstract class UserWorkoutState {
  const UserWorkoutState();
}

class UserWorkoutInitial extends UserWorkoutState {}

class UserWorkoutActive extends UserWorkoutState {
  final UserWorkout userWorkout;
  final Map<int, List<List<int>>> previousData;

  UserWorkoutActive(this.userWorkout, this.previousData);
}

class UserWorkoutFinish extends UserWorkoutState {}

class UserWorkoutLoaded extends UserWorkoutState {
  final Map<DateTime, List<UserWorkout>> events;

  UserWorkoutLoaded(this.events);
}

class DetailUserWorkout extends UserWorkoutState {
  final Map<int, List<Map<DateTime, List<int>>>> previousData;

  DetailUserWorkout(this.previousData);
}

class ExerciseWiseUserWorkout extends UserWorkoutState {
  final List<Map<DateTime, List<int>>> data;

  ExerciseWiseUserWorkout(this.data);
}
