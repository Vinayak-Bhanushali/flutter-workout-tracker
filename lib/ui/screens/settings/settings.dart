import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_tracker/bloc/app_data_bloc/app_data_bloc.dart';
import 'package:workout_tracker/bloc/workout_bloc/workout_bloc.dart';
import 'package:workout_tracker/datasources/local/sembast_database/app_database.dart';
import 'package:workout_tracker/models/enums.dart';
import 'package:workout_tracker/models/workout.dart';
import 'package:workout_tracker/ui/widgets/common_widgets.dart';
import 'package:workout_tracker/ui/widgets/custom_choice_chip.dart';
import 'package:workout_tracker/ui/widgets/custom_dialogue.dart';
import 'package:workout_tracker/uitilities/route_generator.dart';
import 'package:workout_tracker/uitilities/widget_helper.dart';
import 'package:workout_tracker/uitilities/custom_extensions.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  AppDataBloc _appDataBloc;
  WorkoutBloc _workoutBloc;

  static const Map<int, String> weekDays = {
    7: "S",
    1: "M",
    2: "T",
    3: "W",
    4: "T",
    5: "F",
    6: "S",
  };

  @override
  void initState() {
    super.initState();
    // Obtaining the WorkoutBloc instance through BlocProvider which is an InheritedWidget
    _appDataBloc = BlocProvider.of<AppDataBloc>(context);
    _workoutBloc = BlocProvider.of<WorkoutBloc>(context);
    // Events can be passed into the bloc by calling dispatch.
    // We want to start loading  wrokouts from the start.
    _workoutBloc.add(LoadWorkouts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                userInfo(context),
                const Divider(),
                remainder(context),
                const Divider(),
                themePicker(context),
                const Divider(),
                ...workout(context),
                const Divider(),
                // TODO remove this on prod
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RaisedButton(
                      onPressed: () async {
                        TextEditingController controller =
                            TextEditingController();
                        await showDialog(
                          context: context,
                          child: AlertDialog(
                            content: TextField(
                              controller: controller,
                            ),
                          ),
                        );
                        if (controller.text.isNotEmpty)
                          AppDatabase.instance.import(controller.text);
                      },
                      child: Text("Import"),
                    ),
                    RaisedButton(
                      onPressed: () async {
                        Clipboard.setData(
                          ClipboardData(
                            text: await AppDatabase.instance.export(),
                          ),
                        );
                      },
                      child: Text("Export"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget userInfo(BuildContext context) {
    return Row(
      children: [
        Hero(
          tag: "UserImage",
          child: CircleAvatar(
            child: Icon(Icons.person_outline_rounded),
          ),
        ),
        Spacer(),
        Expanded(
            flex: 14,
            child: BlocBuilder<AppDataBloc, AppDataState>(
              cubit: _appDataBloc,
              builder: (context, state) {
                if (state is AppDataLoaded)
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () async {
                          var result = await CustomDialog.inputDialog(
                            title: "Enter Name",
                            context: context,
                          );
                          if (result != null && result != '') {
                            state.appData.userData.name = result;
                            _appDataBloc.add(
                              AppDataUpdate(state.appData),
                            );
                          }
                        },
                        child: state.appData.userData.name != null
                            ? Text(
                                state.appData.userData.name,
                                style: Theme.of(context).textTheme.subtitle1,
                              )
                            : Text(
                                "name",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .color
                                          .withOpacity(0.4),
                                    ),
                              ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () async {
                              var result = await CustomDialog.inputDialog(
                                title: "Enter age",
                                context: context,
                                defaultText:
                                    state.appData.userData.age.toString(),
                                hintText: "in years",
                                textInputType: TextInputType.numberWithOptions(
                                  signed: false,
                                  decimal: false,
                                ),
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              );
                              if (result != null && result != '') {
                                state.appData.userData.age = int.parse(result);
                                _appDataBloc.add(
                                  AppDataUpdate(state.appData),
                                );
                              }
                            },
                            child: state.appData.userData.age != null
                                ? Text(
                                    state.appData.userData.age.toString() +
                                        " years".addFourSpace(),
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                  )
                                : Text(
                                    "age".addFourSpace(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .color
                                              .withOpacity(0.4),
                                        ),
                                  ),
                          ),
                          InkWell(
                            onTap: () async {
                              var result = await CustomDialog.inputDialog(
                                title: "Enter Weight",
                                context: context,
                                defaultText: state.appData.userData.weight
                                        ?.toStringAsFixed(0) ??
                                    null,
                                hintText: "in kg",
                                textInputType: TextInputType.numberWithOptions(
                                  signed: false,
                                  decimal: true,
                                ),
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              );
                              if (result != null && result != '') {
                                state.appData.userData.weight =
                                    double.parse(result);
                                _appDataBloc.add(
                                  AppDataUpdate(state.appData),
                                );
                              }
                            },
                            child: state.appData.userData.weight != null
                                ? Text(
                                    state.appData.userData.weight.toString() +
                                        " kg".addFourSpace(),
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                  )
                                : Text(
                                    "weight".addFourSpace(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .color
                                              .withOpacity(0.4),
                                        ),
                                  ),
                          ),
                          InkWell(
                            onTap: () async {
                              var result = await CustomDialog.inputDialog(
                                title: "Enter Height",
                                context: context,
                                defaultText: state.appData.userData.height
                                        ?.toStringAsFixed(0) ??
                                    null,
                                hintText: "in cm",
                                textInputType: TextInputType.numberWithOptions(
                                  signed: false,
                                  decimal: true,
                                ),
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              );
                              if (result != null && result != '') {
                                state.appData.userData.height =
                                    double.parse(result);
                                _appDataBloc.add(
                                  AppDataUpdate(state.appData),
                                );
                              }
                            },
                            child: state.appData.userData.height != null
                                ? Text(
                                    state.appData.userData.height.toString() +
                                        " cm".addFourSpace(),
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                  )
                                : Text(
                                    "height".addFourSpace(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .color
                                              .withOpacity(0.4),
                                        ),
                                  ),
                          ),
                        ],
                      )
                    ],
                  );
                else
                  return Container();
              },
            )),
      ],
    );
  }

  Widget remainder(BuildContext context) {
    return BlocBuilder<AppDataBloc, AppDataState>(
      cubit: _appDataBloc,
      builder: (context, state) {
        if (state is AppDataLoaded)
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Remainder",
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Switch(
                    value: state.appData.remainderSettings?.enabled,
                    onChanged: (bool value) {
                      state.appData.remainderSettings.enabled = value;
                      state.appData.remainderSettings.notificationsScheduled =
                          DateTime.now();
                      if (!value)
                        _appDataBloc.add(
                          UpdateRemainderData(state.appData.remainderSettings),
                        );

                      _appDataBloc.add(
                        AppDataUpdate(state.appData),
                      );
                    },
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                      children: weekDays.keys
                          .map(
                            (key) => Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: CustomChoiceChip(
                                label: weekDays[key],
                                selected: state
                                        .appData.remainderSettings?.selectedDays
                                        ?.contains(key) ??
                                    false,
                                onSelected: state.appData.remainderSettings
                                            ?.enabled ??
                                        false
                                    ? (selected) async {
                                        if (selected)
                                          state.appData.remainderSettings
                                              .selectedDays
                                              .add(key);
                                        else
                                          state.appData.remainderSettings
                                              .selectedDays
                                              .remove(key);
                                        _appDataBloc.add(
                                          UpdateRemainderData(
                                              state.appData.remainderSettings),
                                        );
                                        _appDataBloc.add(
                                          AppDataUpdate(state.appData),
                                        );
                                      }
                                    : null,
                              ),
                            ),
                          )
                          .toList()),
                  Flexible(
                    child: InkWell(
                      onTap: () async {
                        if (!(state.appData.remainderSettings?.enabled ?? true))
                          return;
                        final TimeOfDay picked = await showTimePicker(
                          context: context,
                          initialTime: state.appData.remainderSettings.time,
                          helpText: "A notification will be sent at this time",
                        );
                        if (picked != null) {
                          state.appData.remainderSettings.time = picked;
                          _appDataBloc.add(
                            UpdateRemainderData(
                                state.appData.remainderSettings),
                          );
                          _appDataBloc.add(
                            AppDataUpdate(state.appData),
                          );
                        }
                      },
                      child: Text(
                        MediaQuery.of(context).alwaysUse24HourFormat
                            ? "${state.appData.remainderSettings.time.hour}:${state.appData.remainderSettings.time.minute.toString().padLeft(2, '0')}"
                            : "${state.appData.remainderSettings.time.hour % 12}:${state.appData.remainderSettings.time.minute.toString().padLeft(2, '0')} ${state.appData.remainderSettings.time.period.toString().split('.').last}",
                        style: !(state.appData.remainderSettings?.enabled ??
                                true)
                            ? Theme.of(context).textTheme.headline6.copyWith(
                                color: Theme.of(context).disabledColor)
                            : Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  )
                ],
              )
            ],
          );
        else
          return Container();
      },
    );
  }

  Widget themePicker(BuildContext context) {
    return BlocBuilder<AppDataBloc, AppDataState>(
      cubit: _appDataBloc,
      builder: (context, state) {
        if (state is AppDataLoaded)
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Theme",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              Expanded(
                child: Row(
                  children: appThemeValue.reverse.values
                      .map((e) => Expanded(
                            child: CommonWidget.selectableCard(
                              text: e,
                              context: context,
                              isSelected: state.appData.appTheme ==
                                  appThemeValue.map[e],
                              onSelectionChange: (selected) {
                                if (selected)
                                  state.appData.appTheme = appThemeValue.map[e];
                                _appDataBloc.add(
                                  AppDataUpdate(state.appData),
                                );
                              },
                            ),
                          ))
                      .toList(),
                ),
              )
            ],
          );
        else
          return Container();
      },
    );
  }

  List<Widget> workout(BuildContext context) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Workouts",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () async {
              dynamic val = await CustomDialog.inputDialog(
                title: "Enter Workout Name",
                context: context,
              );
              if (val != null && val != '') {
                _workoutBloc.add(
                  InsertWorkout(
                    Workout(
                      name: val,
                    ),
                  ),
                );
              }
            },
          )
        ],
      ),
      BlocBuilder<WorkoutBloc, WorkoutState>(
        cubit: _workoutBloc,
        builder: (context, state) {
          if (state is WorkoutLoading)
            return Center(
              child: CircularProgressIndicator(),
            );
          else if (state is WorkoutLoaded)
            return workoutList(
              state.workouts,
              context,
            );
          else
            return Container();
        },
      ),
    ];
  }

  Widget workoutList(List<Workout> workouts, BuildContext context) {
    return Column(
      children: WidgetHelper.twoElements(
          [workoutCard(true, Workout(name: "All"), context, workouts)] +
              workouts
                  .map(
                    (w) => workoutCard(
                      false,
                      w,
                      context,
                      workouts,
                    ),
                  )
                  .toList()),
    );
  }

  Widget workoutCard(
    bool isAllWorkout,
    Workout selectedWorkout,
    BuildContext context,
    List<Workout> workouts,
  ) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            RouteGenerator.manageExercise,
            arguments: {
              'selectedWorkout': isAllWorkout ? null : selectedWorkout,
              'allWorkouts': workouts,
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedWorkout.name,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
              if (!isAllWorkout)
                InkWell(
                  child: Icon(
                    Icons.delete,
                    size: 18,
                  ),
                  onTap: () {
                    _workoutBloc.add(DeleteWorkout(selectedWorkout));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
