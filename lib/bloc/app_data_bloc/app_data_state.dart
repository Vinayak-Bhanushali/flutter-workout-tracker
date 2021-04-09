part of 'app_data_bloc.dart';

abstract class AppDataState {
  const AppDataState();
}

class AppDataLoading extends AppDataState {}

class AppDataLoaded extends AppDataState {
  final AppData appData;

  AppDataLoaded(this.appData);
}
