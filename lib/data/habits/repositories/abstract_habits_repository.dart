import 'package:dt_test/data/habits/models/done_date.dart';
import 'package:dt_test/data/habits/models/habit.dart';
import 'package:dt_test/data/habits/models/habit_type.dart';


abstract class AbstractHabitsRepository {
  List<Habit> getAllHabits(
      {bool orderByDate = false,
      bool orderAsc = true,
      String titlePart = "",
      HabitType? type});

  Future<Habit> addHabit(Habit habit);

  Future<bool> updateHabit(Habit habit);

  Future<bool> deleteHabit(Habit habit);

  Future<Habit> completeHabit(Habit habit, DoneDate date, bool isNewDate);
}
