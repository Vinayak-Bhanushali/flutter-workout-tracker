import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:workout_tracker/datasources/local/sembast_database/daos/progress_image_dao.dart';
import 'package:workout_tracker/models/timeline.dart';

part 'timeline_event.dart';
part 'timeline_state.dart';

class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  TimelineBloc() : super(TimelineInitial());

  final TimelineDao _timelineDao = TimelineDao();

  @override
  Stream<TimelineState> mapEventToState(
    TimelineEvent event,
  ) async* {
    if (event is LoadAllTimelines) {
      yield AllTimelinesLoaded(
        await _timelineDao.getAllSortedByDate(),
      );
    } else if (event is DeleteTimeline) {
      await _timelineDao.delete(event.timeline);
      yield SingleTimelineLoaded(
        event.timeline,
      );
    } else if (event is InsertTimeline) {
      int id = await _timelineDao.insert(event.timeline);
      event.timeline.id = id;
      yield SingleTimelineLoaded(
        event.timeline,
      );
    } else if (event is UpdateTimeline) {
      await _timelineDao.update(event.timeline);
      yield SingleTimelineLoaded(
        event.timeline,
      );
    }
  }
}
