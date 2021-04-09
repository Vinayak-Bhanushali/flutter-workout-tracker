import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:workout_tracker/ui/widgets/circular_progress_bar.dart';
import 'package:workout_tracker/uitilities/common_functions.dart';

class CountDown extends StatefulWidget {
  final int seconds;

  const CountDown({Key key, @required this.seconds}) : super(key: key);
  @override
  _CountDownState createState() => _CountDownState();
}

class _CountDownState extends State<CountDown> {
  final beep = AssetsAudioPlayer();
  final beepLong = AssetsAudioPlayer();

  Timer _timer;
  int _seconds = 10;
  static const oneSec = const Duration(seconds: 1);

  bool _showReplay = false;

  @override
  void initState() {
    super.initState();
    _seconds = widget.seconds;
    beep.open(
      Audio("assets/audio/beep.mp3"),
      autoStart: false,
      audioFocusStrategy: AudioFocusStrategy.none(),
      volume: 0.8,
    );
    beepLong.open(
      Audio("assets/audio/beep-long.mp3"),
      autoStart: false,
      audioFocusStrategy: AudioFocusStrategy.none(),
      volume: 0.8,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => startTimer());
  }

  @override
  void dispose() {
    beep.dispose();
    beepLong.dispose();
    if (_timer != null) _timer.cancel();
    super.dispose();
  }

  playBeep() {
    stopBeep();
    beep.play();
  }

  stopBeep() {
    beep.stop();
  }

  void playBeepLong() {
    stopBeepLong();
    beepLong.play();
  }

  void stopBeepLong() {
    beepLong.stop();
  }

  Future<void> startTimer() async {
    setState(() {
      _showReplay = false;
    });
    await Future.delayed(Duration(seconds: 5));
    if (mounted) {
      playBeepLong();
      _timer = new Timer.periodic(
        oneSec,
        (Timer timer) => setState(
          () {
            if (_seconds < 1) {
              timer.cancel();
              _seconds = widget.seconds;
              _showReplay = true;
            } else {
              _seconds -= 1;
              if (_seconds == 0) {
                playBeepLong();
              } else if (_seconds <= 5) {
                playBeep();
              }
            }
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleProgressBar(
          foregroundColor: CommonFunctions.progreesBarColor(
            _seconds / widget.seconds,
          ),
          backgroundColor: Theme.of(context).cardColor,
          value: _seconds / widget.seconds,
        ),
        _showReplay
            ? IconButton(
                icon: const Icon(Icons.replay),
                onPressed: startTimer,
                iconSize: 60,
              )
            : Text(
                _seconds.toString(),
                style: Theme.of(context).textTheme.headline2,
              ),
      ],
    );
  }
}
