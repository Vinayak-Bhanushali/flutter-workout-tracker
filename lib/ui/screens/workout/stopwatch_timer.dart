import 'dart:async';

import 'package:flutter/material.dart';

class StopwatchTimer extends StatefulWidget {
  @override
  _StopwatchTimerState createState() => _StopwatchTimerState();
}

class _StopwatchTimerState extends State<StopwatchTimer> {
  String time = "00:00:00";
  final swatch = Stopwatch();
  final duration = const Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    swatch.start();
    startTimer();
  }

  @override
  void dispose() {
    swatch.stop();
    super.dispose();
  }

  void startTimer() {
    Timer(duration, updateTimer);
  }

  void updateTimer() {
    if (mounted) {
      setState(() {
        time = swatch.elapsed.inHours.toString().padLeft(2, "0") +
            ":" +
            (swatch.elapsed.inMinutes % 60).toString().padLeft(2, "0") +
            ":" +
            (swatch.elapsed.inSeconds % 60).toString().padLeft(2, "0");
      });
      startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(time);
  }
}
