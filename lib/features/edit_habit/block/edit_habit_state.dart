part of 'edit_habit_bloc.dart';

abstract class EditHabitState {
  final Habit habit;
  final Habit? initialHabit;
  final String titleErrorMessage;
  final String descriptionErrorMessage;
  final String countErrorMessage;
  final String frequencyErrorMessage;
  final String errorMessage;

  EditHabitState(
      {required this.errorMessage,
      required this.titleErrorMessage,
      required this.descriptionErrorMessage,
      required this.countErrorMessage,
      required this.frequencyErrorMessage,
      required this.habit,
      required this.initialHabit});

  EditHabitState copyWith(
      {String? titleErrorMessage,
      String? descriptionErrorMessage,
      String? countErrorMessage,
      String? frequencyErrorMessage,
      Habit? habit,
      Habit? initialHabit,
      String? errorMessage});
}

class EditHabitBaseState extends EditHabitState {
  EditHabitBaseState({
    required super.errorMessage,
    required super.titleErrorMessage,
    required super.descriptionErrorMessage,
    required super.countErrorMessage,
    required super.frequencyErrorMessage,
    required super.habit,
    required super.initialHabit,
  });

  @override
  EditHabitBaseState copyWith(
      {String? titleErrorMessage,
      String? descriptionErrorMessage,
      String? countErrorMessage,
      String? frequencyErrorMessage,
      Habit? habit,
      Habit? initialHabit,
      String? errorMessage}) {
    return EditHabitBaseState(
        titleErrorMessage: titleErrorMessage ?? this.titleErrorMessage,
        descriptionErrorMessage:
            descriptionErrorMessage ?? this.descriptionErrorMessage,
        countErrorMessage: countErrorMessage ?? this.countErrorMessage,
        frequencyErrorMessage:
            frequencyErrorMessage ?? this.frequencyErrorMessage,
        habit: habit ?? this.habit,
        initialHabit: initialHabit ?? this.initialHabit,
        errorMessage: errorMessage ?? this.errorMessage);
  }
}

class EditHabitUpdatingState extends EditHabitState {
  EditHabitUpdatingState({
    required super.errorMessage,
    required super.titleErrorMessage,
    required super.descriptionErrorMessage,
    required super.countErrorMessage,
    required super.frequencyErrorMessage,
    required super.habit,
    required super.initialHabit,
  });

  @override
  EditHabitUpdatingState copyWith(
      {String? titleErrorMessage,
      String? descriptionErrorMessage,
      String? countErrorMessage,
      String? frequencyErrorMessage,
      Habit? habit,
      Habit? initialHabit,
      String? errorMessage}) {
    return EditHabitUpdatingState(
        titleErrorMessage: titleErrorMessage ?? this.titleErrorMessage,
        descriptionErrorMessage:
            descriptionErrorMessage ?? this.descriptionErrorMessage,
        countErrorMessage: countErrorMessage ?? this.countErrorMessage,
        frequencyErrorMessage:
            frequencyErrorMessage ?? this.frequencyErrorMessage,
        habit: habit ?? this.habit,
        initialHabit: initialHabit ?? this.initialHabit,
        errorMessage: errorMessage ?? this.errorMessage);
  }
}
