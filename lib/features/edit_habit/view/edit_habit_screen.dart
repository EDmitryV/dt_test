import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dt_test/features/edit_habit/block/edit_habit_bloc.dart';
import 'package:dt_test/features/edit_habit/widgets/error_field.dart';
import 'package:dt_test/data/habits/repositories/api_habits_repository.dart';
import 'package:dt_test/data/habits/repositories/local_habits_repository.dart';
import 'package:dt_test/data/habits/models/habit.dart';
import 'package:dt_test/data/habits/models/habit_priority.dart';
import 'package:dt_test/data/habits/models/habit_type.dart';
import 'package:dt_test/services/date_int_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';

@RoutePage()
class EditHabitScreen extends StatefulWidget {
  const EditHabitScreen({super.key, required this.habit});
  final Habit? habit;

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  final EditHabitBloc _editHabitBloc = EditHabitBloc(
      GetIt.I<ApiHabitsRepository>(),
      GetIt.I<LocalHabitsRepository>(),
      GetIt.I<DateIntConverter>());
  late final FToast _fToast;
  @override
  void initState() {
    _fToast = FToast();
    _editHabitBloc.add(ScreenOpenedEvent(initialHabit: widget.habit));
    super.initState();
  }

  @override
  void dispose() {
    _editHabitBloc.add(ScreenDisposedEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditHabitBloc, EditHabitState>(
      bloc: _editHabitBloc,
      builder: (context, state) {
        String title;
        if (state.initialHabit == null) {
          title = "Создание привычки";
        } else {
          title = "Изменение привычки";
        }
        Widget body;
        if (state is EditHabitBaseState) {
          if (state.errorMessage.isNotEmpty) {
            _showMessage(state.errorMessage);
            _editHabitBloc.add(EndErrorMessageNotification());
          }
          body = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: state.habit.title,
                  onChanged: (value) =>
                      _editHabitBloc.add(ValidateTitleEvent(title: value)),
                  decoration: const InputDecoration(labelText: 'Название'),
                ),
                if (state.titleErrorMessage.isNotEmpty)
                  ErrorField(error: state.titleErrorMessage),
                TextFormField(
                  initialValue: state.habit.description,
                  onChanged: (value) => _editHabitBloc
                      .add(ValidateDescriptionEvent(description: value)),
                  decoration: const InputDecoration(labelText: 'Описание'),
                ),
                if (state.descriptionErrorMessage.isNotEmpty)
                  ErrorField(error: state.descriptionErrorMessage),
                DropdownButtonFormField<HabitPriority>(
                  value: state.habit.priority,
                  items: [
                    HabitPriority.low,
                    HabitPriority.medium,
                    HabitPriority.high
                  ].map((priority) {
                    return DropdownMenuItem<HabitPriority>(
                      value: priority,
                      child: Text(priority.displayRuName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _editHabitBloc.add(UpdatePriorityEvent(priority: value));
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Приоритет'),
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(HabitType.good.displayRuName),
                      Radio<HabitType>(
                        value: HabitType.good,
                        groupValue: state.habit.type,
                        onChanged: (HabitType? value) {
                          if (value != null) {
                            _editHabitBloc.add(UpdateTypeEvent(type: value));
                          }
                        },
                      ),
                    ]),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(HabitType.bad.displayRuName),
                      Radio<HabitType>(
                        value: HabitType.bad,
                        groupValue: state.habit.type,
                        onChanged: (HabitType? value) {
                          if (value != null) {
                            _editHabitBloc.add(UpdateTypeEvent(type: value));
                          }
                        },
                      ),
                    ]),
                  ],
                ),
                TextFormField(
                  initialValue: state.habit.count.toString(),
                  onChanged: (value) =>
                      _editHabitBloc.add(ValidateCountEvent(count: value)),
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Количество выполнений'),
                ),
                if (state.countErrorMessage.isNotEmpty)
                  ErrorField(error: state.countErrorMessage),
                TextFormField(
                  initialValue: state.habit.frequency.toString(),
                  onChanged: (value) => _editHabitBloc
                      .add(ValidateFrequencyEvent(frequency: value)),
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'За сколько дней'),
                ),
                if (state.frequencyErrorMessage.isNotEmpty)
                  ErrorField(error: state.frequencyErrorMessage),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Цвет привычки:"),
                    const SizedBox(
                      width: 8,
                    ),
                    InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.blueGrey, width: 1.0),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(24),
                            ),
                            color: state.habit.color),
                      ),
                      onTap: () {
                        showDialog(
                          builder: (context) {
                            Color pickerColor = state.habit.color;
                            return AlertDialog(
                              title: const Text('Выберите цвет привычки'),
                              content: SingleChildScrollView(
                                child: MaterialPicker(
                                  pickerColor: pickerColor,
                                  onColorChanged: (color) => _editHabitBloc
                                      .add(UpdateColorEvent(color: color)),
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text('Выйти'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            );
                          },
                          context: context,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.save),
                      onPressed: () {
                        final completer = Completer();
                        _editHabitBloc
                            .add(CreateOrSaveEvent(completer: completer));
                        completer.future.then((actualState) {
                          if (actualState.errorMessage == null ||
                              actualState.errorMessage!.isEmpty) {
                            AutoRouter.of(context).pop();
                          }
                        });
                      },
                      label: const Text('Сохранить'),
                    ),
                    if (state.initialHabit != null)
                      TextButton.icon(
                          onPressed: () {
                            final completer = Completer();
                            _editHabitBloc
                                .add(DeleteEvent(completer: completer));
                            completer.future.then((actualState) {
                              if (actualState.errorMessage == null ||
                                  actualState.errorMessage!.isEmpty) {
                                AutoRouter.of(context).pop();
                              }
                            });
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text("Удалить"))
                  ],
                )
              ],
            ),
          );
        } else {
          body = const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop()),
            title: Text(title),
            actions: [
              if (kDebugMode)
                IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TalkerScreen(
                            talker: GetIt.I<Talker>(),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.info))
            ],
          ),
          body: body,
        );
      },
    );
  }

  _showMessage(String message) {
    _fToast.init(context);
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Theme.of(context).colorScheme.error,
      ),
      child: Text(message),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fToast.showToast(
        child: toast,
        gravity: ToastGravity.CENTER,
        toastDuration: const Duration(seconds: 3),
      );
    });
  }
}
