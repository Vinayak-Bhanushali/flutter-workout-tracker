part of 'timeline_bloc.dart';

abstract class TimelineEvent extends Equatable {
  const TimelineEvent();

  @override
  List<Object> get props => [];
}

class LoadAllTimelines extends TimelineEvent {}

class InsertTimeline extends TimelineEvent {
  final Timeline timeline;

  InsertTimeline(this.timeline);
}

class DeleteTimeline extends TimelineEvent {
  final Timeline timeline;

  DeleteTimeline(this.timeline);
}

class UpdateTimeline extends TimelineEvent {
  final Timeline timeline;

  UpdateTimeline(this.timeline);
}
