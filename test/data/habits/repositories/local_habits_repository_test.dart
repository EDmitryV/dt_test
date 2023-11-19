import 'package:dt_test/data/habits/models/done_date.dart';
import 'package:dt_test/data/habits/models/habit.dart';
import 'package:dt_test/data/habits/models/habit_status.dart';
import 'package:dt_test/data/habits/repositories/local_habits_repository.dart';
import 'package:dt_test/services/date_int_converter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/mockito.dart';

//Тесты не работают, так как я не успел разобраться с работой mockito при null-safety
class MockHabitsBox extends Mock implements Box<Habit> {}

void main() {
  group('LocalHabitsRepository', () {
    late LocalHabitsRepository habitsRepository;
    late MockHabitsBox mockHabitsBox;
    final DateIntConverter dateIntConverter = DateIntConverter();

    setUp(() {
      mockHabitsBox = MockHabitsBox();
      habitsRepository = LocalHabitsRepository(habitsBox: mockHabitsBox);
    });

    test('getAllHabits returns correct list', () {
      final habit1 = Habit(
          title: 'Habit 1',
          date: dateIntConverter.parseNumFromDate(DateTime.now()));
      final habit2 = Habit(
          title: 'Habit 2',
          date: dateIntConverter
              .parseNumFromDate(DateTime.now().add(const Duration(days: 1))));

      when(mockHabitsBox.values).thenReturn(<Habit>[habit1, habit2]);

      final result =
          habitsRepository.getAllHabits(orderByDate: true, orderAsc: true);

      expect(result, [habit1, habit2]);
    });

    test('addHabit adds habit correctly', () async {
      final habit = Habit(
          date: dateIntConverter.parseNumFromDate(DateTime.now()),
          title: 'New Habit',
          status: HabitStatus.synchronized);

      await habitsRepository.addHabit(habit);

      habit.status = HabitStatus.normal;
      verify(mockHabitsBox.add(habit)).captured.single;
    });

    test('updateHabit updates habit correctly', () async {
      final habit = Habit(
          date: dateIntConverter.parseNumFromDate(DateTime.now()),
          title: 'Updated Habit',
          status: HabitStatus.synchronized);

      await habitsRepository.updateHabit(habit);
      habit.status = HabitStatus.normal;

      verify(mockHabitsBox.put(habit.key, habit)).captured.single;
    });

    test('deleteHabit deletes habit correctly', () async {
      final habit = Habit(
          date: dateIntConverter.parseNumFromDate(DateTime.now()),
          title: 'To be deleted',
          status: HabitStatus.synchronized);

      await habitsRepository.deleteHabit(habit);

      verify(mockHabitsBox.delete(habit.key)).captured.single;
    });

    test("completeHabit updates habit's done dates correctly", () async {
      final habit = Habit(
          date: dateIntConverter.parseNumFromDate(DateTime.now()),
          title: 'Complete Habit',
          status: HabitStatus.synchronized);
      final doneDate = DoneDate(
          date: dateIntConverter.parseNumFromDate(DateTime.now()),
          synchronized: true);

      await habitsRepository.completeHabit(habit, doneDate, true);
      habit.doneDates.add(doneDate);
      habit.status = HabitStatus.normal;
      verify(mockHabitsBox.put(habit.key, habit))
          .captured
          .single
          .doneDates
          .contains(doneDate);
    });
  });
}
