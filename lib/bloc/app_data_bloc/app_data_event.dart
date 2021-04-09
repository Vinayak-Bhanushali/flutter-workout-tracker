part of 'app_data_bloc.dart';

abstract class AppDataEvent extends Equatable {
  const AppDataEvent();

  @override
  List<Object> get props => [];
}

class AppDataLoad extends AppDataEvent {}

class AppDataUpdate extends AppDataEvent {
  final AppData appData;

  AppDataUpdate(this.appData);

  @override
  List<Object> get props => [appData];
}

class UpdateRemainderData extends AppDataEvent {
  final RemainderSettings remainderSettings;

  UpdateRemainderData(this.remainderSettings);

  @override
  List<Object> get props => [remainderSettings];
}
