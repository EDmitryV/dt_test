part of 'habit_list_bloc.dart';

abstract class HabitListEvent {}

class ScreenOpenedEvent extends HabitListEvent {
  final Completer? completer;

  ScreenOpenedEvent({required this.completer});
}

class LoadHabitsListEvent extends HabitListEvent {
  final Completer? completer;
  final bool orderByDate;
  final bool orderAsc;
  final String titlePart;
  final HabitType type;

  LoadHabitsListEvent(
      {this.completer,
      this.orderByDate = false,
      this.orderAsc = true,
      this.titlePart = '',
      this.type = HabitType.good});
}

class HabitCompletedEvent extends HabitListEvent {
  final Habit completedHabit;
  final int completedHabitIdx;

  HabitCompletedEvent(
      {required this.completedHabitIdx, required this.completedHabit});
}

class EndCompleteMessageNotificationEvent extends HabitListEvent {}

class ScreenDisposedEvent extends HabitListEvent {}

class ChangeTitleFilterEvent extends HabitListEvent {
  final String titleFilter;

  ChangeTitleFilterEvent({required this.titleFilter});
}

class ChangeDateSortEvent extends HabitListEvent {
  ChangeDateSortEvent({required this.orderByDate, required this.orderAsc});
  final bool orderByDate;
  final bool orderAsc;
}
