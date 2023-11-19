import 'package:dio/dio.dart';
import 'package:dt_test/consts.dart';
import 'package:dt_test/data/habits/models/done_date.dart';
import 'package:dt_test/data/habits/models/habit.dart';
import 'package:dt_test/data/habits/models/habit_status.dart';
import 'package:dt_test/data/habits/models/habit_type.dart';
import 'package:dt_test/data/habits/repositories/abstract_habits_repository.dart';
import 'package:dt_test/data/habits/repositories/local_habits_repository.dart';
import 'package:dt_test/services/date_int_converter.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:collection/collection.dart';

class ApiHabitsRepository extends AbstractHabitsRepository {
  final LocalHabitsRepository _localHabitsRepository;
  final Dio _dio;
  final DateIntConverter _utils;
  ApiHabitsRepository(
      {required DateIntConverter utils,
      required LocalHabitsRepository localHabitsRepository,
      required Dio dio})
      : _localHabitsRepository = localHabitsRepository,
        _dio = dio,
        _utils = utils;

  Future<void> synchronizeHabits() async {
    //Синхронизация локального хранилища с сервером (кроме удаления)
    List<Habit> habitsNoUid = _localHabitsRepository.getAllHabits(
        onlyNoUid: true, orderAsc: false, orderByDate: true);
    List<Habit> localHabitsSorted =
        _localHabitsRepository.getAllHabits(orderByDate: true, orderAsc: false);
    var i = 0;
    while (true) {
      var remoteHabitsPart = await _getRemoteHabits(
          offset: i,
          limit: habitsListLoadLimit,
          orderByDate: true,
          orderAsc: false);
      if (remoteHabitsPart.isEmpty) break;
      var end = false;
      for (var remoteHabit in remoteHabitsPart) {
        if (localHabitsSorted.firstWhereOrNull((h) =>
                h.title == remoteHabit.title && h.date == remoteHabit.date) ==
            null) {
          remoteHabit.status = HabitStatus.synchronized;
          await _localHabitsRepository.addHabit(remoteHabit);
        } else {
          var habitNoUid = habitsNoUid.firstWhereOrNull((h) =>
              h.title == remoteHabit.title && h.date == remoteHabit.date);
          if (habitNoUid != null) {
            habitNoUid.uid = remoteHabit.uid;
            habitNoUid.status = HabitStatus.synchronized;
            await _localHabitsRepository.updateHabit(habitNoUid);
            habitsNoUid.remove(habitNoUid);
          }
          if (habitsNoUid.isEmpty) {
            end = true;
            break;
          }
        }
      }
      if (end) break;
      i += habitsListLoadLimit;
    }
    //Синхронизация сервера с локальным хранилищем
    var habitsNotSync = _localHabitsRepository.getAllHabits(onlyNotSync: true);
    for (var h in habitsNotSync) {
      var deleted = false;
      switch (h.status) {
        case HabitStatus.created:
          h.status = HabitStatus.synchronized;
          await _localHabitsRepository.deleteHabit(h);
          await addHabit(h);
          break;
        case HabitStatus.updated:
          await updateHabit(h);
          break;
        case HabitStatus.deleted:
          await deleteHabit(h);
          deleted = true;
          break;
        default:
          break;
      }
      if (!deleted && !h.doneDatesSynchronized) {
        for (var d in h.doneDates) {
          if (!d.synchronized) {
            completeHabit(h, d, false);
          }
        }
      }
    }
    //Синхронизация локального хранилища с сервером (удаление)
    localHabitsSorted =
        _localHabitsRepository.getAllHabits(orderByDate: true, orderAsc: false);
    i = 0;
    var j = 0;
    var remoteHabitsPart = [];
    var toDelete = [];
    for (var i = 0; i < localHabitsSorted.length; i++) {
      if (j % habitsListLoadLimit == 0) {
        remoteHabitsPart = await _getRemoteHabits(
            offset: i,
            limit: habitsListLoadLimit,
            orderByDate: true,
            orderAsc: false);
      }
      if (j % habitsListLoadLimit >= remoteHabitsPart.length ||
          i >= localHabitsSorted.length) break;
      var rh = remoteHabitsPart[j % habitsListLoadLimit];
      var lh = localHabitsSorted[i];
      while (lh.date > rh.date) {
        toDelete.add(lh);
        i++;
        lh = localHabitsSorted[i];
      }
    }
    for (Habit h in toDelete) {
      h.status = HabitStatus.synchronized;
      await _localHabitsRepository.deleteHabit(h);
    }
  }

  Future<List<Habit>> _getRemoteHabits({
    required int offset,
    required int limit,
    bool orderByDate = false,
    bool orderAsc = true,
    String? titlePart = "",
    HabitType? type,
  }) async {
    try {
      var response = await _dio.get(habitsInternshipUrl,
          queryParameters: {
            "offset": offset,
            "limit": limit,
            if (orderByDate) "order_by": "date",
            "order_direction": orderAsc ? "asc" : "desc",
            if (type != null) "type": type.value,
            if (titlePart != null && titlePart != "") "title": titlePart
          },
          options: Options(headers: {
            "accept": "application/json",
            "Authorization": habitsInternshipToken,
          }));
      if (response.statusCode == 200) {
        return response.data['habits'] != null && response.data['count'] > 0
            ? response.data['habits']
                .map<Habit>((hm) => Habit.fromMap(hm))
                .toList()
            : [];
      } else {
        return [];
      }
    } catch (e, st) {
      GetIt.instance<Talker>().handle(e, st);
      return [];
    }
  }

  @override
  List<Habit> getAllHabits({
    bool orderByDate = false,
    bool orderAsc = true,
    String? titlePart = "",
    HabitType? type,
  }) {
    return _localHabitsRepository.getAllHabits(
        orderByDate: orderByDate,
        orderAsc: orderAsc,
        titlePart: titlePart,
        type: type);
  }

  @override
  Future<Habit> addHabit(Habit habit) async {
    try {
      var response = await _dio.post(habitsInternshipUrl,
          data: habit.toMap(),
          options: Options(headers: {
            "accept": "application/json",
            "Authorization": habitsInternshipToken,
            "Content-Type": "application/json"
          }));
      if (habit.status == HabitStatus.created) {
        return habit;
      } else {
        if (response.statusCode == 200) {
          var h = Habit.fromMap(response.data);
          h.status = HabitStatus.synchronized;
          return await _localHabitsRepository.addHabit(h);
        } else {
          return await _localHabitsRepository.addHabit(habit);
        }
      }
    } catch (e, st) {
      GetIt.I<Talker>().handle(e, st);
      if (habit.status != HabitStatus.created) {
        return await _localHabitsRepository.addHabit(habit);
      } else {
        return habit;
      }
    }
  }

  @override
  Future<bool> updateHabit(Habit habit) async {
    try {
      habit.date = _utils.parseNumFromDate(DateTime.now());
      var response = await _dio.patch("$habitsInternshipUrl/${habit.uid}",
          data: habit.toMap(),
          options: Options(headers: {
            "accept": "application/json",
            "Authorization": habitsInternshipToken,
            "Content-Type": "application/json"
          }));
      if (response.statusCode == 200 && response.data['success']) {
        habit.status = HabitStatus.synchronized;
      }
      return await _localHabitsRepository.updateHabit(habit);
    } catch (e, st) {
      GetIt.I<Talker>().handle(e, st);
      return await _localHabitsRepository.updateHabit(habit);
    }
  }

  @override
  Future<bool> deleteHabit(Habit habit) async {
    try {
      var response = await _dio.delete("$habitsInternshipUrl/${habit.uid}",
          options: Options(headers: {
            "accept": "application/json",
            "Authorization": habitsInternshipToken
          }));
      if (response.statusCode == 200 && response.data['success']) {
        habit.status = HabitStatus.synchronized;
      }
      return await _localHabitsRepository.deleteHabit(habit);
    } catch (e, st) {
      GetIt.I<Talker>().handle(e, st);
      return await _localHabitsRepository.deleteHabit(habit);
    }
  }

  @override
  Future<Habit> completeHabit(
      Habit habit, DoneDate date, bool isNewDate) async {
    try {
      var response = await _dio.post(
          "$habitsInternshipUrl/${habit.uid}/complete",
          data: {"date": date.date},
          options: Options(headers: {
            "accept": "application/json",
            "Authorization": habitsInternshipToken
          }));
      return _localHabitsRepository.completeHabit(
          habit,
          date.copyWith(
              synchronized: response.statusCode == 200 &&
                  response.data["success"] as bool),
          isNewDate);
    } catch (e, st) {
      GetIt.I<Talker>().handle(e, st);
      return _localHabitsRepository.completeHabit(
          habit, date.copyWith(synchronized: false), isNewDate);
    }
  }
}
