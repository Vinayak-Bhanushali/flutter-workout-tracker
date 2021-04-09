part of 'timeline_bloc.dart';

abstract class TimelineState {
  const TimelineState();
}

class TimelineInitial extends TimelineState {}

class AllTimelinesLoaded extends TimelineState {
  final List<Timeline> timelines;

  AllTimelinesLoaded(this.timelines);
}

class SingleTimelineLoaded extends TimelineState {
  final Timeline timeline;

  SingleTimelineLoaded(this.timeline);
}
