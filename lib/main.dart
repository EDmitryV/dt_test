import 'dart:async';
import 'package:dio/dio.dart';
import 'package:dt_test/consts.dart';
import 'package:dt_test/data/habits/models/done_date.dart';
import 'package:dt_test/data/habits/models/habit.dart';
import 'package:dt_test/data/habits/models/habit_priority.dart';
import 'package:dt_test/data/habits/models/habit_status.dart';
import 'package:dt_test/data/habits/models/habit_type.dart';
import 'package:dt_test/theme/theme.dart';
import 'package:dt_test/data/habits/repositories/api_habits_repository.dart';
import 'package:dt_test/data/habits/repositories/local_habits_repository.dart';
import 'package:dt_test/router/router.dart';
import 'package:dt_test/services/date_int_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    GetIt.I.registerLazySingleton<DateIntConverter>(() => DateIntConverter());

    //Регистрация логирования
    final talker = TalkerFlutter.init();
    GetIt.I.registerSingleton(talker);
    Bloc.observer = TalkerBlocObserver(
        talker: talker,
        settings: const TalkerBlocLoggerSettings(
            printStateFullData: false, printEventFullData: false));
    FlutterError.onError =
        (details) => GetIt.I<Talker>().handle(details.exception, details.stack);

    //Регистрация репозиториев
    await Hive.initFlutter();
    Hive.registerAdapter(ColorAdapter());
    Hive.registerAdapter(HabitTypeAdapter());
    Hive.registerAdapter(DoneDateAdapter());
    Hive.registerAdapter(HabitPriorityAdapter());
    Hive.registerAdapter(HabitStatusAdapter());
    Hive.registerAdapter(HabitAdapter());
    final habitBox = await Hive.openBox<Habit>(habitsBoxName);

    GetIt.I.registerLazySingleton<LocalHabitsRepository>(
        () => LocalHabitsRepository(habitsBox: habitBox));
    final Dio dio = Dio();
    dio.interceptors.add(TalkerDioLogger(
        talker: talker,
        settings: const TalkerDioLoggerSettings(printResponseData: false)));
    GetIt.I.registerLazySingleton<ApiHabitsRepository>(() =>
        ApiHabitsRepository(
            localHabitsRepository: GetIt.I<LocalHabitsRepository>(),
            dio: dio,
            utils: GetIt.I<DateIntConverter>()));

    runApp(const DoubletappTest());
  }, (error, stack) => GetIt.I<Talker>().handle(error, stack));
}

class DoubletappTest extends StatefulWidget {
  const DoubletappTest({super.key});

  @override
  State<DoubletappTest> createState() => _DoubletappTestState();
}

class _DoubletappTestState extends State<DoubletappTest> {
  final _appRouter = AppRouter();
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      builder: FToastBuilder(),
      title: 'Трекер привычек',
      theme: lightTheme,
      routerConfig: _appRouter.config(
          navigatorObservers: () => [
                TalkerRouteObserver(GetIt.I<Talker>()),
              ]),
    );
  }
}
