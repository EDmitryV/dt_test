import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dt_test/consts.dart';
import 'package:dt_test/data/habits/models/done_date.dart';
import 'package:dt_test/data/habits/models/habit.dart';
import 'package:dt_test/data/habits/repositories/abstract_habits_repository.dart';
import 'package:dt_test/data/habits/repositories/api_habits_repository.dart';
import 'package:dt_test/data/habits/repositories/local_habits_repository.dart';
import 'package:dt_test/data/habits/models/habit_type.dart';
import 'package:dt_test/services/date_int_converter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

part 'habit_list_event.dart';
part 'habit_list_state.dart';

class HabitListBloc extends Bloc<HabitListEvent, HabitListState> {
  HabitListBloc(
      this.apiHabitsRepository, this.localHabitsRepository, this.utils)
      : super(HabitListInitState()) {
    on<ScreenOpenedEvent>((event, emit) async {
      await Hive.openBox<Habit>(habitsBoxName);
      await _initRepository();
      if (state is ListContainingState) {
        var currentState = state as ListContainingState;
        await _loadHabitsList(
            LoadHabitsListEvent(
                orderByDate: currentState.orderByDate,
                orderAsc: currentState.orderAsc,
                titlePart: currentState.titlePart,
                type: currentState.type),
            emit);
      } else {
        await _loadHabitsList(
            LoadHabitsListEvent(
                orderByDate: false,
                orderAsc: true,
                titlePart: "",
                type: HabitType.good),
            emit);
      }
    });

    on<ScreenDisposedEvent>((event, emit) async {
      await connectivitySubscription.cancel();
    });

    on<LoadHabitsListEvent>((event, emit) async {
      await _loadHabitsList(event, emit);
    });

    on<HabitCompletedEvent>((event, emit) async {
      await _completeHabit(event, emit);
    });

    on<EndCompleteMessageNotificationEvent>((event, emit) async {
      await _endNotification(event, emit);
    });

    on<ChangeTitleFilterEvent>((event, emit) async {
      if (state is ListContainingState) {
        ListContainingState previousState = state as ListContainingState;
        await _loadHabitsList(
            LoadHabitsListEvent(
                orderByDate: previousState.orderByDate,
                orderAsc: previousState.orderAsc,
                titlePart: event.titleFilter,
                type: previousState.type),
            emit);
      } else {
        await _loadHabitsList(
            LoadHabitsListEvent(
                orderByDate: false,
                orderAsc: true,
                titlePart: event.titleFilter,
                type: HabitType.good),
            emit);
      }
    });

    on<ChangeDateSortEvent>((event, emit) async {
      if (state is ListContainingState) {
        ListContainingState previousState = state as ListContainingState;
        await _loadHabitsList(
            LoadHabitsListEvent(
                orderByDate: event.orderByDate,
                orderAsc: event.orderAsc,
                titlePart: previousState.titlePart,
                type: previousState.type),
            emit);
      } else {
        await _loadHabitsList(
            LoadHabitsListEvent(
                orderByDate: event.orderByDate,
                orderAsc: event.orderAsc,
                titlePart: "",
                type: HabitType.good),
            emit);
      }
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
      await apiHabitsRepository.synchronizeHabits();
    }
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result == ConnectivityResult.none ||
          result == ConnectivityResult.bluetooth) {
        actualRepository = localHabitsRepository;
      } else {
        actualRepository = apiHabitsRepository;
        await apiHabitsRepository.synchronizeHabits();
      }
    });
  }

  Future<void> _loadHabitsList(
      LoadHabitsListEvent event, Emitter<HabitListState> emit) async {
    if (state is! HabitListLoadingState) {
      emit(HabitListLoadingState(
          orderByDate: event.orderByDate,
          orderAsc: event.orderAsc,
          titlePart: event.titlePart,
          type: event.type,
          message: ""));
    }
    try {
      final habitsList = actualRepository.getAllHabits(
          orderByDate: event.orderByDate,
          orderAsc: event.orderAsc,
          titlePart: event.titlePart,
          type: event.type);
      emit(HabitsListLoadedState(
          habitsList: habitsList,
          offset: 0,
          orderByDate: event.orderByDate,
          orderAsc: event.orderAsc,
          titlePart: event.titlePart,
          type: event.type,
          message: ""));
    } catch (e, st) {
      emit(HabitListErrorState());
      GetIt.I<Talker>().handle(e, st);
    } finally {
      event.completer?.complete();
    }
  }

  Future<void> _completeHabit(
      HabitCompletedEvent event, Emitter<HabitListState> emit) async {
    var habit = event.completedHabit;
    try {
      var completedHabit = await actualRepository.completeHabit(
          habit,
          DoneDate(
              date: utils.parseNumFromDate(DateTime.now()),
              synchronized: false),
          true);
      int days = 1;
      int amount = 0;
      while (amount < habit.doneDates.length &&
          amount < habit.count &&
          DateTime.now()
                  .difference(utils.parseDateFromNum(habit
                      .doneDates[habit.doneDates.length - amount - 1].date))
                  .inDays <
              habit.frequency) {
        days = DateTime.now()
                .difference(utils.parseDateFromNum(
                    habit.doneDates[habit.doneDates.length - amount - 1].date))
                .inDays +
            1;
        amount++;
      }
      String message;
      if (amount / days < habit.count / habit.frequency) {
        if (habit.type == HabitType.bad) {
          message = "Можете выполнить еще ${habit.count - amount} раз";
        } else {
          message = "Стоит выполнить еще ${habit.count - amount} раз";
        }
      } else {
        if (habit.type == HabitType.bad) {
          message = "Хватит это делать";
        } else {
          message = "You are breathtaking!";
        }
      }
      ListContainingState previousState = state as ListContainingState;
      if (state is HabitsListLoadedState) {
        var habitList = previousState.habitsList;
        habitList.removeAt(event.completedHabitIdx);
        habitList.insert(event.completedHabitIdx, completedHabit);
        emit(HabitsListLoadedState(
            message: message,
            habitsList: habitList,
            offset: previousState.offset,
            orderByDate: previousState.orderByDate,
            orderAsc: previousState.orderAsc,
            titlePart: previousState.titlePart,
            type: previousState.type));
      }
    } catch (e, st) {
      emit(HabitListErrorState());
      GetIt.I<Talker>().handle(e, st);
    }
  }

  Future<void> _endNotification(EndCompleteMessageNotificationEvent event,
      Emitter<HabitListState> emit) async {
    ListContainingState previousState = state as ListContainingState;
    if (state is HabitsListLoadedState) {
      emit(HabitsListLoadedState(
          habitsList: previousState.habitsList,
          offset: previousState.offset,
          orderByDate: previousState.orderByDate,
          orderAsc: previousState.orderAsc,
          titlePart: previousState.titlePart,
          type: previousState.type,
          message: ""));
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    GetIt.I<Talker>().handle(error, stackTrace);
  }
}
