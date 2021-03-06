import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:workout_tracker/models/enums.dart';
import 'package:workout_tracker/models/exercise.dart';
import 'package:workout_tracker/ui/screens/homescreen/statistics/indicator.dart';
import 'package:workout_tracker/uitilities/common_functions.dart';
import 'package:workout_tracker/uitilities/custom_extensions.dart';

class StatisticsAlert extends StatefulWidget {
  final String month;
  final Exercise exercise;
  final List<Map<DateTime, List<int>>> data;

  const StatisticsAlert({
    Key key,
    @required this.month,
    @required this.exercise,
    @required this.data,
  }) : super(key: key);
  @override
  _StatisticsAlertState createState() => _StatisticsAlertState();
}

class _StatisticsAlertState extends State<StatisticsAlert> {
  List<List<int>> data = [];
  int maxSets = 0;
  int maxReps = 0;
  int minReps;
  int maxDays = 0;
  int minDays = 31;
  double intervalX = 1;
  double intervalY = 1;
  @override
  void initState() {
    super.initState();
    minReps = widget.data.first.values.first.first;
    for (var item in widget.data) {
      for (var setData in item.values) {
        if (maxSets < setData.length) maxSets = setData.length;
      }
    }
    for (var item in widget.data) {
      for (var setData in item.values) {
        for (var i = 0; i < maxSets; i++) {
          if (data.length <= i) {
            data.add([]);
          }
          if (i < setData.length) {
            data[i].add(setData[i]);
            if (setData[i] > maxReps) maxReps = setData[i];
            if (setData[i] < minReps) minReps = setData[i];
          } else {
            data[i].add(null);
          }
        }
      }
    }
    maxDays = widget.data.first.keys.first.day;
    minDays = widget.data.last.keys.last.day;
    if (maxDays > minDays + 5) intervalX = (maxDays - minDays) / 5;
    if (maxReps > minReps + 5) intervalY = (maxReps - minReps) / 5;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
        child: Center(
          child: Material(
            color: Theme.of(context).dialogBackgroundColor,
            elevation: 24.0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(4.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Hero(
                  tag: widget.exercise.id,
                  child: Text(
                    widget.exercise.name,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    data.length,
                    (index) => Indicator(
                      color: CommonFunctions.indicatorColors[
                          index % CommonFunctions.indicatorColors.length],
                      text: "Set ${index + 1}",
                      isSquare: false,
                      textColor: Theme.of(context).textTheme.bodyText1.color,
                      size: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              tooltipBgColor: Theme.of(context).canvasColor,
                              showOnTopOfTheChartBoxArea: true,
                              getTooltipItems: (touchedSpots) {
                                List<LineTooltipItem> data = [];
                                for (var i = 0; i < touchedSpots.length; i++) {
                                  if (i == 0)
                                    data.add(
                                      LineTooltipItem(
                                        "${touchedSpots[i].x.toStringAsFixed(0)} ${widget.month.substring(0, 3)} \n\n ${touchedSpots[i].y.toStringAsFixed(0)} ",
                                        Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(
                                              color: CommonFunctions
                                                      .indicatorColors[
                                                  i %
                                                      CommonFunctions
                                                          .indicatorColors
                                                          .length],
                                            ),
                                      ),
                                    );
                                  else
                                    data.add(
                                      LineTooltipItem(
                                        "${touchedSpots[i].y.toStringAsFixed(0)} ",
                                        Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(
                                              color: CommonFunctions
                                                      .indicatorColors[
                                                  i %
                                                      CommonFunctions
                                                          .indicatorColors
                                                          .length],
                                            ),
                                      ),
                                    );
                                }
                                return data;
                              },
                            ),
                            touchCallback: (LineTouchResponse touchResponse) {},
                            handleBuiltInTouches: true,
                          ),
                          axisTitleData: FlAxisTitleData(
                            rightTitle: AxisTitle(
                              titleText: unitFullFormValues
                                  .reverse[widget.exercise.unit],
                              textStyle: Theme.of(context).textTheme.bodyText1,
                              showTitle: true,
                            ),
                            bottomTitle: AxisTitle(
                              titleText: widget.month,
                              textStyle: Theme.of(context).textTheme.bodyText1,
                              showTitle: true,
                            ),
                          ),
                          gridData: FlGridData(
                            show: false,
                          ),
                          titlesData: FlTitlesData(
                            bottomTitles: SideTitles(
                              showTitles: true,
                              getTextStyles: (value) =>
                                  Theme.of(context).textTheme.caption,
                              margin: 10,
                              interval: intervalX,
                              getTitles: (value) => value.toStringAsFixed(0),
                            ),
                            leftTitles: SideTitles(
                              showTitles: true,
                              interval: intervalY,
                              getTextStyles: (value) =>
                                  Theme.of(context).textTheme.caption,
                              getTitles: (value) => value.toStringAsFixed(0),
                              margin: 8,
                            ),
                          ),
                          maxY: maxReps + intervalY,
                          minY:
                              minReps - intervalY > 0 ? minReps - intervalY : 0,
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(context).canvasColor,
                                width: 4,
                              ),
                              left: BorderSide(
                                color: Colors.transparent,
                              ),
                              right: BorderSide(
                                color: Colors.transparent,
                              ),
                              top: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                          lineBarsData: enumerate(data)
                              .map(
                                (e) => LineChartBarData(
                                  colors: [
                                    CommonFunctions.indicatorColors[e.key %
                                        CommonFunctions.indicatorColors.length]
                                  ],
                                  barWidth: 4,
                                  isStrokeCapRound: true,
                                  // curveSmoothness: 0,
                                  isCurved: false,
                                  dotData: FlDotData(show: false),
                                  belowBarData: BarAreaData(show: false),
                                  spots: generateSpots(e.value),
                                ),
                              )
                              .toList(),
                        ),
                        swapAnimationDuration:
                            const Duration(milliseconds: 250),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<FlSpot> generateSpots(List<int> values) {
    List<FlSpot> spots = [];
    for (var i = 0; i < values.length; i++) {
      if (values[i] != null) {
        spots.add(
          FlSpot(
            widget.data[i].keys.first.day.toDouble(),
            values[i].toDouble(),
          ),
        );
      }
    }
    return spots;
  }
}
