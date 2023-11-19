part of 'habit_list_bloc.dart';

abstract class HabitListState {}

abstract class ListContainingState extends HabitListState {
  final List<Habit> habitsList;
  final int offset;
  final int limit;
  final bool orderByDate;
  final bool orderAsc;
  final String titlePart;
  final HabitType type;
  final String message;

  ListContainingState(
    this.habitsList,
    this.offset,
    this.limit,
    this.orderByDate,
    this.orderAsc,
    this.titlePart,
    this.type,
    this.message,
  );
}

class HabitListInitState extends HabitListState {}

class HabitListLoadingState extends ListContainingState {
  HabitListLoadingState(
      {required bool orderByDate,
      required bool orderAsc,
      required String titlePart,
      required HabitType type,
      required String message})
      : super([], 0, habitsListLoadLimit * 2, orderByDate, orderAsc, titlePart,
            type, message);
}

class HabitsListLoadedState extends ListContainingState {
  HabitsListLoadedState({
    required List<Habit> habitsList,
    required int offset,
    required bool orderByDate,
    required bool orderAsc,
    required String titlePart,
    required HabitType type,
    required String message,
  }) : super(habitsList, offset, habitsListLoadLimit, orderByDate, orderAsc,
            titlePart, type, message);
}

class HabitListErrorState extends HabitListState {}
