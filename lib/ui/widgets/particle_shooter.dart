import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:workout_tracker/uitilities/common_functions.dart';

class ParticleShooter extends StatefulWidget {
  final Alignment alignment;

  const ParticleShooter({Key key, this.alignment}) : super(key: key);
  @override
  _ParticleShooterState createState() => _ParticleShooterState();
}

class _ParticleShooterState extends State<ParticleShooter> {
  final ConfettiController _controller = ConfettiController(
    duration: const Duration(seconds: 1),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Add to timeline if atleast one goal is completed
      _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: ConfettiWidget(
        confettiController: _controller,
        blastDirection:
            widget.alignment == Alignment.bottomLeft ? -pi / 2.5 : -pi / 1.7,
        shouldLoop: false,
        emissionFrequency: 0.01,
        numberOfParticles: 20,
        maxBlastForce: 100,
        colors: CommonFunctions.particleColors,
      ),
    );
  }
}
