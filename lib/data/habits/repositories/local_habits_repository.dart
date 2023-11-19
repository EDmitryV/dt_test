import 'package:dt_test/data/habits/models/done_date.dart';
import 'package:dt_test/data/habits/models/habit.dart';
import 'package:dt_test/data/habits/models/habit_status.dart';
import 'package:dt_test/data/habits/repositories/abstract_habits_repository.dart';
import 'package:dt_test/data/habits/models/habit_type.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalHabitsRepository extends AbstractHabitsRepository {
  final Box<Habit> _habitsBox;

  LocalHabitsRepository({required Box<Habit> habitsBox})
      : _habitsBox = habitsBox;

  @override
  List<Habit> getAllHabits(
      {bool orderByDate = false,
      bool orderAsc = true,
      String? titlePart = "",
      bool onlyNotSync = false,
      HabitType? type,
      bool onlyNoUid = false}) {
    var habits = _habitsBox.values.toList();
    if (onlyNoUid) {
      habits = habits.where((h) => h.uid.isEmpty).toList();
    }
    if (onlyNotSync) {
      habits = habits
          .where((h) => (!onlyNotSync || h.status != HabitStatus.normal))
          .where((h) => !onlyNotSync || (type != null ? h.type == type : true))
          .toList();
    }
    if (titlePart != null && titlePart.isNotEmpty) {
      habits = habits.where((h) => h.title.contains(titlePart)).toList();
    }
    if (type != null) {
      habits = habits.where((h) => h.type == type).toList();
    }
    if (orderByDate) {
      habits.sort((h1, h2) => h1.date.compareTo(h2.date));
    }
    return orderAsc ? habits : habits.reversed.toList();
  }

  @override
  Future<Habit> addHabit(Habit habit) async {
    if (habit.status == HabitStatus.synchronized) {
      habit.status = HabitStatus.normal;
      _habitsBox.add(habit);
    } else {
      habit.status = HabitStatus.created;
      _habitsBox.add(habit);
    }
    return habit;
  }

  @override
  Future<bool> updateHabit(Habit habit) async {
    if (habit.status == HabitStatus.synchronized) {
      habit.status = HabitStatus.normal;
      _habitsBox.put(habit.key, habit);
      
    } else if (habit.status == HabitStatus.created) {
      _habitsBox.put(habit.key, habit);
      
    } else {
      habit.status = HabitStatus.updated;
      _habitsBox.put(habit.key, habit);
      
    }
    return true;
  }

  @override
  Future<bool> deleteHabit(Habit habit) async {
    if (habit.status == HabitStatus.synchronized ||
        habit.status == HabitStatus.created) {
      _habitsBox.delete(habit.key);
      
    } else {
      habit.status = HabitStatus.deleted;
      _habitsBox.put(habit.key, habit);
      
    }
    return true;
  }

  @override
  Future<Habit> completeHabit(
      Habit habit, DoneDate date, bool isNewDate) async {
    if (!date.synchronized) {
      habit.doneDatesSynchronized = false;
    } else if (habit.doneDates.isEmpty || habit.doneDates.last.synchronized) {
      habit.doneDatesSynchronized = true;
    }
    if (isNewDate) {
      habit.doneDates.add(date);
    } else {
      var idx =
          habit.doneDates.indexWhere((element) => element.date == date.date);
      habit.doneDates.removeAt(idx);
      habit.doneDates.insert(idx, date);
    }
    _habitsBox.put(habit.key, habit);
    
    return habit;
  }
}
