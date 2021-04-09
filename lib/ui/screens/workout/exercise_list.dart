import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_tracker/bloc/exercise_bloc/exercise_bloc.dart';
import 'package:workout_tracker/models/workout.dart';
import 'package:workout_tracker/uitilities/widget_helper.dart';

class ExerciseList extends StatefulWidget {
  final Workout workout;

  const ExerciseList({Key key, @required this.workout}) : super(key: key);
  @override
  _ExerciseListState createState() => _ExerciseListState();
}

class _ExerciseListState extends State<ExerciseList> {
  ExerciseBloc _exerciseBloc;

  @override
  void initState() {
    super.initState();
    _exerciseBloc = BlocProvider.of<ExerciseBloc>(context);
    _exerciseBloc.add(LoadExercises(
      workout: widget.workout,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseBloc, ExerciseState>(
      cubit: _exerciseBloc,
      builder: (context, state) {
        if (state is ExerciseLoaded) {
          return SingleChildScrollView(
            child: Column(
              children: WidgetHelper.twoElements(
                state.exercises
                    .map(
                      (e) => Text(
                        "• ${e.name}",
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .copyWith(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                    .toList(),
                verticalSpacing: 8.0,
              ),
            ),
          );
        } else
          return Container();
      },
    );
  }
}
