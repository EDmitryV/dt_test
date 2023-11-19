part of 'edit_habit_bloc.dart';

abstract class EditHabitEvent {}

class ScreenOpenedEvent extends EditHabitEvent {
  ScreenOpenedEvent({
    required this.initialHabit,
  });
  Habit? initialHabit;
}

class ScreenDisposedEvent extends EditHabitEvent {}

class ValidateTitleEvent extends EditHabitEvent {
  final String title;

  ValidateTitleEvent({required this.title});
}

class ValidateDescriptionEvent extends EditHabitEvent {
  final String description;

  ValidateDescriptionEvent({required this.description});
}

class UpdatePriorityEvent extends EditHabitEvent {
  final HabitPriority priority;

  UpdatePriorityEvent({required this.priority});
}

class UpdateTypeEvent extends EditHabitEvent {
  final HabitType type;

  UpdateTypeEvent({required this.type});
}

class UpdateColorEvent extends EditHabitEvent {
  final Color color;

  UpdateColorEvent({required this.color});
}

class ValidateCountEvent extends EditHabitEvent {
  final String count;

  ValidateCountEvent({required this.count});
}

class ValidateFrequencyEvent extends EditHabitEvent {
  final String frequency;

  ValidateFrequencyEvent({required this.frequency});
}

class CreateOrSaveEvent extends EditHabitEvent {
  CreateOrSaveEvent({required this.completer});
  Completer completer;
}

class DeleteEvent extends EditHabitEvent {
  DeleteEvent({required this.completer});
  Completer completer;
}

class EndErrorMessageNotification extends EditHabitEvent {}
