import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dt_test/consts.dart';
import 'package:dt_test/data/habits/repositories/abstract_habits_repository.dart';
import 'package:dt_test/data/habits/repositories/api_habits_repository.dart';
import 'package:dt_test/data/habits/repositories/local_habits_repository.dart';
import 'package:dt_test/data/habits/models/habit.dart';
import 'package:dt_test/data/habits/models/habit_priority.dart';
import 'package:dt_test/data/habits/models/habit_type.dart';
import 'package:dt_test/services/date_int_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

part 'edit_habit_event.dart';
part 'edit_habit_state.dart';

class EditHabitBloc extends Bloc<EditHabitEvent, EditHabitState> {
  EditHabitBloc(
      this.apiHabitsRepository, this.localHabitsRepository, this.utils)
      : super(EditHabitUpdatingState(
            titleErrorMessage: "",
            descriptionErrorMessage: "",
            countErrorMessage: "",
            frequencyErrorMessage: "",
            errorMessage: '',
            habit: Habit(date: utils.parseNumFromDate(DateTime.now())),
            initialHabit: null)) {
    on<ScreenOpenedEvent>((event, emit) async {
      Habit h;
      if (event.initialHabit != null) {
        h = Habit(date: utils.parseNumFromDate(DateTime.now()));
        h.copyParamsFrom(habit: event.initialHabit!);
      } else {
        h = state.habit;
      }
      emit(state.copyWith(initialHabit: event.initialHabit, habit: h));
      await Hive.openBox<Habit>(habitsBoxName);
      await _initRepository();
      emit(EditHabitBaseState(
          titleErrorMessage: state.titleErrorMessage,
          descriptionErrorMessage: state.descriptionErrorMessage,
          countErrorMessage: state.countErrorMessage,
          frequencyErrorMessage: state.frequencyErrorMessage,
          habit: state.habit,
          initialHabit: state.initialHabit,
          errorMessage: state.errorMessage));
    });

    on<ScreenDisposedEvent>((event, emit) async {
      await connectivitySubscription.cancel();
    });

    on<ValidateTitleEvent>((event, emit) async {
      await _validateTitle(event, emit);
    });

    on<ValidateDescriptionEvent>((event, emit) async {
      await _validateDescription(event, emit);
    });

    on<UpdatePriorityEvent>((event, emit) async {
      state.habit.priority = event.priority;
      emit(state.copyWith());
    });

    on<UpdateTypeEvent>((event, emit) async {
      state.habit.type = event.type;
      emit(state.copyWith());
    });

    on<UpdateColorEvent>((event, emit) async {
      state.habit.color = event.color;
      emit(state.copyWith());
    });

    on<ValidateCountEvent>((event, emit) async {
      _validateCount(event, emit);
    });

    on<ValidateFrequencyEvent>((event, emit) async {
      _validateFrequency(event, emit);
    });

    on<CreateOrSaveEvent>((event, emit) async {
      await _validateTitle(ValidateTitleEvent(title: state.habit.title), emit);
      await _validateDescription(
          ValidateDescriptionEvent(description: state.habit.description), emit);
      await _validateCount(
          ValidateCountEvent(count: state.habit.count.toString()), emit);
      await _validateFrequency(
          ValidateFrequencyEvent(frequency: state.habit.frequency.toString()),
          emit);
      if ([
        state.titleErrorMessage,
        state.countErrorMessage,
        state.frequencyErrorMessage
      ].where((e) => e.isNotEmpty).isNotEmpty) {
        emit(state.copyWith(
            errorMessage: "Некоторые поля заполнены неправильно"));
        event.completer.complete(state);
        return;
      }
      emit(EditHabitUpdatingState(
          titleErrorMessage: state.titleErrorMessage,
          descriptionErrorMessage: state.descriptionErrorMessage,
          countErrorMessage: state.countErrorMessage,
          frequencyErrorMessage: state.frequencyErrorMessage,
          habit: state.habit,
          initialHabit: state.initialHabit,
          errorMessage: state.errorMessage));
      try {
        if (state.initialHabit == null) {
          final habit = await actualRepository.addHabit(state.habit);
          emit(EditHabitUpdatingState(
              titleErrorMessage: state.titleErrorMessage,
              descriptionErrorMessage: state.descriptionErrorMessage,
              countErrorMessage: state.countErrorMessage,
              frequencyErrorMessage: state.frequencyErrorMessage,
              habit: habit,
              initialHabit: state.initialHabit,
              errorMessage: state.errorMessage));
        } else {
          if (await actualRepository.updateHabit(
              state.initialHabit!.copyParamsFrom(habit: state.habit))) {
            emit(EditHabitUpdatingState(
                titleErrorMessage: state.titleErrorMessage,
                descriptionErrorMessage: state.descriptionErrorMessage,
                countErrorMessage: state.countErrorMessage,
                frequencyErrorMessage: state.frequencyErrorMessage,
                habit: state.habit,
                initialHabit: state.initialHabit,
                errorMessage: state.errorMessage));
          } else {
            emit(EditHabitBaseState(
                titleErrorMessage: state.titleErrorMessage,
                descriptionErrorMessage: state.descriptionErrorMessage,
                countErrorMessage: state.countErrorMessage,
                frequencyErrorMessage: state.frequencyErrorMessage,
                habit: state.habit,
                errorMessage: "Ошибка при обновлении привычки",
                initialHabit: state.initialHabit));
          }
        }
      } catch (e, st) {
        emit(EditHabitBaseState(
            titleErrorMessage: state.titleErrorMessage,
            descriptionErrorMessage: state.descriptionErrorMessage,
            countErrorMessage: state.countErrorMessage,
            frequencyErrorMessage: state.frequencyErrorMessage,
            habit: state.habit,
            errorMessage: state.initialHabit == null
                ? "Ошибка при создании привычки"
                : "Ошибка при обновлении привычки",
            initialHabit: state.initialHabit));
        GetIt.I<Talker>().handle(e, st);
      } finally {
        event.completer.complete(state);
      }
    });

    on<DeleteEvent>((event, emit) async {
      emit(EditHabitUpdatingState(
          titleErrorMessage: state.titleErrorMessage,
          descriptionErrorMessage: state.descriptionErrorMessage,
          countErrorMessage: state.countErrorMessage,
          frequencyErrorMessage: state.frequencyErrorMessage,
          habit: state.habit,
          initialHabit: state.initialHabit,
          errorMessage: state.errorMessage));
      try {
        if (await actualRepository.deleteHabit(state.initialHabit!)) {
          emit(EditHabitUpdatingState(
              titleErrorMessage: state.titleErrorMessage,
              descriptionErrorMessage: state.descriptionErrorMessage,
              countErrorMessage: state.countErrorMessage,
              frequencyErrorMessage: state.frequencyErrorMessage,
              habit: state.habit,
              initialHabit: state.initialHabit,
              errorMessage: state.errorMessage));
        } else {
          emit(EditHabitBaseState(
              titleErrorMessage: state.titleErrorMessage,
              descriptionErrorMessage: state.descriptionErrorMessage,
              countErrorMessage: state.countErrorMessage,
              frequencyErrorMessage: state.frequencyErrorMessage,
              habit: state.habit,
              errorMessage: "Ошибка при удалении привычки",
              initialHabit: state.initialHabit));
        }
      } catch (e, st) {
        emit(EditHabitBaseState(
            titleErrorMessage: state.titleErrorMessage,
            descriptionErrorMessage: state.descriptionErrorMessage,
            countErrorMessage: state.countErrorMessage,
            frequencyErrorMessage: state.frequencyErrorMessage,
            habit: state.habit,
            errorMessage: "Ошибка при удалении привычки",
            initialHabit: state.initialHabit));
        GetIt.I<Talker>().handle(e, st);
      } finally {
        event.completer.complete(state);
      }
    });

    on<EndErrorMessageNotification>((event, emit) async {
      emit(state.copyWith(errorMessage: ""));
    });
  }

  final ApiHabitsRepository apiHabitsRepository;
  final LocalHabitsRepository localHabitsRepository;
  final DateIntConverter utils;
  late final StreamSubscription<ConnectivityResult> connectivitySubscription;
  late AbstractHabitsRepository actualRepository;

  Future<void> _initRepository() async {
    actualRepository = localHabitsRepository;
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none ||
        connectivityResult == ConnectivityResult.bluetooth) {
      actualRepository = localHabitsRepository;
    } else {
      actualRepository = apiHabitsRepository;
      apiHabitsRepository.synchronizeHabits();
    }
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none ||
          result == ConnectivityResult.bluetooth) {
        actualRepository = localHabitsRepository;
      } else {
        actualRepository = apiHabitsRepository;
        apiHabitsRepository.synchronizeHabits();
      }
    });
  }

  Future<void> _validateTitle(
      ValidateTitleEvent event, Emitter<EditHabitState> emit) async {
    if (event.title.isEmpty) {
      emit(state.copyWith(titleErrorMessage: "Название не должно быть пустым"));
    } else {
      state.habit.title = event.title;
      emit(state.copyWith(titleErrorMessage: ""));
    }
  }

  Future<void> _validateDescription(
      ValidateDescriptionEvent event, Emitter<EditHabitState> emit) async {
    if (event.description.isEmpty) {
      emit(state.copyWith(
          descriptionErrorMessage: "Описание не должно быть пустым"));
    } else {
      state.habit.description = event.description;
      emit(state.copyWith(descriptionErrorMessage: ""));
    }
  }

  Future<void> _validateCount(
      ValidateCountEvent event, Emitter<EditHabitState> emit) async {
    if (event.count.isEmpty) {
      emit(state.copyWith(
          countErrorMessage: "Количество выполнений не должно быть пустым"));
    } else if (int.tryParse(event.count) == null) {
      emit(state.copyWith(
          countErrorMessage: "Количество выполнений должно быть целым числом"));
    } else if (int.parse(event.count) <= 0) {
      emit(state.copyWith(
          countErrorMessage: "Количество выполнений должно быть больше чем 0"));
    } else {
      state.habit.count = int.parse(event.count);
      emit(state.copyWith(countErrorMessage: ""));
    }
  }

  Future<void> _validateFrequency(
      ValidateFrequencyEvent event, Emitter<EditHabitState> emit) async {
    if (event.frequency.isEmpty) {
      emit(state.copyWith(
          frequencyErrorMessage:
              "Число дней на выполнение не должно быть пустым"));
    } else if (int.tryParse(event.frequency) == null) {
      emit(state.copyWith(
          frequencyErrorMessage:
              "Число дней на выполнение должно быть целым числом"));
    } else if (int.parse(event.frequency) <= 0) {
      emit(state.copyWith(
          frequencyErrorMessage:
              "Число дней на выполнение должно быть больше чем 0"));
    } else {
      state.habit.frequency = int.parse(event.frequency);
      emit(state.copyWith(frequencyErrorMessage: ""));
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    GetIt.I<Talker>().handle(error, stackTrace);
  }
}
