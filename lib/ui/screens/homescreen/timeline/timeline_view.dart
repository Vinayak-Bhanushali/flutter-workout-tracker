import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:workout_tracker/bloc/timeline_bloc/timeline_bloc.dart';
import 'package:workout_tracker/models/enums.dart';
import 'package:workout_tracker/models/timeline.dart';
import 'package:workout_tracker/ui/widgets/hero_dialog_route.dart';
import 'package:workout_tracker/uitilities/common_functions.dart';
import 'package:workout_tracker/uitilities/date_formatter.dart';
import 'package:workout_tracker/uitilities/custom_extensions.dart';

class TimeLineView extends StatefulWidget {
  @override
  _TimeLineViewState createState() => _TimeLineViewState();
}

class _TimeLineViewState extends State<TimeLineView> {
  TimelineBloc _timelineBloc;

  @override
  void initState() {
    super.initState();
    _timelineBloc = BlocProvider.of<TimelineBloc>(context);
    _timelineBloc.add(LoadAllTimelines());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimelineBloc, TimelineState>(
      cubit: _timelineBloc,
      builder: (context, state) {
        if (state is AllTimelinesLoaded)
          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: state.timelines.isEmpty
                      ? []
                      : _timelineTree(state.timelines.reversed.toList()),
                ),
              ),
            ),
          );
        else
          return Scaffold(
            body: CircularProgressIndicator(),
          );
      },
    );
  }

  List<Widget> _timelineTree(List<Timeline> timelines) {
    List<Widget> children = [];
    bool showImagesToRight = true;
    int colorIndex = 1;
    Color beforeColor = CommonFunctions
        .indicatorColors[CommonFunctions.indicatorColors.length % colorIndex];
    Color afterColor = CommonFunctions
        .indicatorColors[CommonFunctions.indicatorColors.length % colorIndex];
    children.add(
      month(
        DateFormatter.monthTextAndYear.format(timelines.first.date),
        beforeColor,
        afterColor,
        isFirst: true,
      ),
    );
    children.add(leftToCenterDivider(beforeColor));
    for (var i = 0; i < timelines.length; i++) {
      if (i > 0 && timelines[i - 1].date.month != timelines[i].date.month) {
        showImagesToRight = !showImagesToRight;
        !showImagesToRight
            ? children.add(leftToCenterDivider(beforeColor))
            : children.add(rightToCenterDivider(beforeColor));
        colorIndex++;
        afterColor = CommonFunctions.indicatorColors[
            CommonFunctions.indicatorColors.length % colorIndex];
        children.add(month(
          DateFormatter.monthTextAndYear.format(timelines[i].date),
          beforeColor,
          afterColor,
        ));
        beforeColor = afterColor;
        showImagesToRight
            ? children.add(leftToCenterDivider(afterColor))
            : children.add(rightToCenterDivider(afterColor));
      }
      children.add(
        TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: showImagesToRight ? 0.2 : 0.8,
          beforeLineStyle: LineStyle(color: beforeColor),
          indicatorStyle: IndicatorStyle(
            indicator: day(timelines[i].date.day, beforeColor),
            width: 36,
            height: 36,
            drawGap: true,
          ),
          startChild: showImagesToRight
              ? workoutName(timelines[i].workout?.name ?? "All")
              : timelineDetail(timelines[i], MainAxisAlignment.end),
          endChild: showImagesToRight
              ? timelineDetail(timelines[i], MainAxisAlignment.start)
              : workoutName(timelines[i].workout.name),
        ),
      );
    }
    children.add(
      showImagesToRight
          ? leftToCenterDivider(beforeColor)
          : rightToCenterDivider(beforeColor),
    );
    children.add(month("END", beforeColor, afterColor, isLast: true));

    return children;
  }

  leftToCenterDivider(Color color) {
    return TimelineDivider(
      begin: 0.2,
      end: 0.5,
      thickness: 4,
      color: color,
    );
  }

  rightToCenterDivider(Color color) {
    return TimelineDivider(
      begin: 0.5,
      end: 0.8,
      thickness: 4,
      color: color,
    );
  }

  Widget month(
    String label,
    Color beforColor,
    Color afterColor, {
    bool isFirst = false,
    isLast = false,
  }) {
    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      beforeLineStyle: LineStyle(color: beforColor),
      afterLineStyle: LineStyle(color: afterColor),
      alignment: TimelineAlign.center,
      indicatorStyle: IndicatorStyle(
        width: 200,
        height: 50,
        drawGap: false,
        indicator: Center(
          child: Card(
            color: afterColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget day(int day, Color borderColor) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: 3,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          day.toString().padLeft(2, "0"),
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
    );
  }

  Widget workoutName(String name) {
    return Card(
      shape: CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.caption,
        ),
      ),
    );
  }

  Widget timelineDetail(
    Timeline timeline,
    MainAxisAlignment mainAxisAlignment,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          children: [
            if (timeline.imageData.isNotEmpty)
              FutureBuilder<List<File>>(
                future: CommonFunctions.generateImageList(
                  timeline.imageData,
                  onImageNotFound: (imagePath) {
                    print(imagePath);
                    timeline.imageData.remove(imagePath);
                    if (timeline.imageData.isEmpty &&
                        timeline.goalsData.isEmpty)
                      _timelineBloc.add(DeleteTimeline(timeline));
                    else
                      _timelineBloc.add(UpdateTimeline(timeline));
                    _timelineBloc.add(LoadAllTimelines());
                  },
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done)
                    return images(snapshot.data, mainAxisAlignment);
                  else
                    return const CircularProgressIndicator();
                },
              ),
            if (timeline.imageData.isNotEmpty && timeline.goalsData.isNotEmpty)
              const SizedBox(height: 8),
            if (timeline.goalsData.isNotEmpty)
              goal(timeline.goalsData, mainAxisAlignment),
          ],
        ),
      ),
    );
  }

  Widget images(List<File> imageData, MainAxisAlignment mainAxisAlignment) {
    return CarouselSlider(
      options: CarouselOptions(
        enableInfiniteScroll: false,
        autoPlay: true,
        disableCenter: true,
        aspectRatio: 1,
      ),
      items: imageData
          .map(
            (e) => InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  HeroDialogRoute(
                    context: context,
                    builder: (BuildContext context) {
                      TransformationController controller =
                          TransformationController();
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        child: InteractiveViewer(
                          boundaryMargin: EdgeInsets.all(40.0),
                          transformationController: controller,
                          minScale: 1,
                          child: Hero(
                            tag: e,
                            child: Image.file(e),
                          ),
                          onInteractionEnd: (ScaleEndDetails endDetails) {
                            controller.value = Matrix4.identity();
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              child: Hero(
                tag: e,
                child: Image.file(e),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget goal(List<GoalData> goalsData, MainAxisAlignment mainAxisAlignment) {
    return CarouselSlider(
      options: CarouselOptions(
        enableInfiniteScroll: false,
        autoPlay: true,
        disableCenter: true,
        aspectRatio: 3.2,
        viewportFraction: 0.6,
      ),
      items: goalsData
          .map(
            (e) => Card(
              margin: EdgeInsets.symmetric(horizontal: 2.0),
              color: Colors.green,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DefaultTextStyle(
                  style: const TextStyle(color: Colors.white),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: Text(
                          "${e.exerciseName}",
                          style: Theme.of(context).textTheme.subtitle1.copyWith(
                                color: Colors.white,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text(
                        "${e.value}",
                        style: Theme.of(context).textTheme.headline6.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      Text(
                        "${unitFullFormValues.reverse[e.unit].isMultiple(e.value)} completed in Set ${e.setNo}",
                        style: Theme.of(context).textTheme.caption.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
