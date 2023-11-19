import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dt_test/features/habit_list/block/habit_list_bloc.dart';
import 'package:dt_test/features/habit_list/widgets/bottom_sheet_widget.dart';
import 'package:dt_test/features/habit_list/widgets/fake_habit_list_tile.dart';
import 'package:dt_test/features/habit_list/widgets/habit_list_tile.dart';
import 'package:dt_test/data/habits/repositories/api_habits_repository.dart';
import 'package:dt_test/data/habits/repositories/local_habits_repository.dart';
import 'package:dt_test/data/habits/models/habit_type.dart';
import 'package:dt_test/router/router.dart';
import 'package:dt_test/services/date_int_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';

@RoutePage()
class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  late final FToast _fToast;
  final _habitListBloc = HabitListBloc(GetIt.I<ApiHabitsRepository>(),
      GetIt.I<LocalHabitsRepository>(), GetIt.I<DateIntConverter>());

  @override
  void initState() {
    _habitListBloc.add(ScreenOpenedEvent(completer: null));
    _fToast = FToast();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitListBloc, HabitListState>(
        bloc: _habitListBloc,
        builder: (context, state) {
          if (state is ListContainingState) {
            if (state.message.isNotEmpty) {
              _showMessage(state.message);
              _habitListBloc.add(EndCompleteMessageNotificationEvent());
            }
          }
          const paddings =
              EdgeInsets.only(top: 16, bottom: 200, left: 40, right: 40);
          Widget body;
          if (state is HabitsListLoadedState) {
            body = ListView.separated(
              padding: paddings,
              itemCount: state.habitsList.length,
              separatorBuilder: (context, index) => const SizedBox(
                height: 12,
              ),
              itemBuilder: (context, i) {
                final habit = state.habitsList[i];
                return HabitListTile(
                    habit: habit, idx: i, bloc: _habitListBloc);
              },
            );
          } else if (state is HabitListErrorState) {
            body = Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Что-то пошло не так',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    'Пожалуйста попробуйте зайти позже',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: () {
                      _habitListBloc.add(LoadHabitsListEvent(
                          orderByDate: false,
                          orderAsc: true,
                          titlePart: "",
                          type: HabitType.good));
                    },
                    child: const Text('Перезагрузить'),
                  ),
                ],
              ),
            );
          } else {
            body = ListView.separated(
              padding: paddings,
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(
                height: 12,
              ),
              itemBuilder: (context, i) {
                return const FakeHabitListTile();
              },
            );
          }
          return Scaffold(
              floatingActionButton: FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () => AutoRouter.of(context)
                      .push(EditHabitRoute(habit: null))
                      .then((value) =>
                          _habitListBloc.add(LoadHabitsListEvent()))),
              bottomNavigationBar: state is ListContainingState
                  ? NavigationBar(
                      selectedIndex: state.type.value.toInt(),
                      indicatorColor: state.type.value == 0
                          ? Colors.green.withAlpha(50)
                          : Colors.red.withAlpha(50),
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(
                            Icons.sentiment_satisfied_outlined,
                            color: Colors.black,
                          ),
                          selectedIcon: Icon(
                            Icons.sentiment_satisfied_outlined,
                            color: Colors.green,
                          ),
                          label: 'Хорошие',
                        ),
                        NavigationDestination(
                          icon: Icon(
                            Icons.sentiment_dissatisfied_outlined,
                            color: Colors.black,
                          ),
                          selectedIcon: Icon(
                            Icons.sentiment_dissatisfied_outlined,
                            color: Colors.red,
                          ),
                          label: 'Плохие',
                        ),
                      ],
                      onDestinationSelected: (int index) {
                        _habitListBloc.add(LoadHabitsListEvent(
                            orderByDate: state.orderByDate,
                            orderAsc: state.orderAsc,
                            titlePart: state.titlePart,
                            type: HabitType.getByValue(index)));
                      },
                    )
                  : null,
              bottomSheet: state is ListContainingState
                  ? BottomSheetWidget(
                      orderByDate: state.orderByDate,
                      orderAsc: state.orderAsc,
                      titlePart: state.titlePart,
                      bloc: _habitListBloc,
                      state: state,
                    )
                  : null,
              appBar: AppBar(
                title: const Text("Список привычек"),
                actions: [
                  if (kDebugMode)
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TalkerScreen(
                                talker: GetIt.I<Talker>(),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info))
                ],
              ),
              body: RefreshIndicator(
                  onRefresh: () async {
                    final completer = Completer();
                    if (state is! ListContainingState) {
                      _habitListBloc.add(LoadHabitsListEvent(
                          completer: completer,
                          orderByDate: false,
                          orderAsc: true,
                          titlePart: "",
                          type: HabitType.good));
                    } else {
                      _habitListBloc.add(LoadHabitsListEvent(
                          completer: completer,
                          orderByDate: state.orderByDate,
                          orderAsc: state.orderAsc,
                          titlePart: state.titlePart,
                          type: state.type));
                    }
                    return completer.future;
                  },
                  child: body));
        });
  }

  @override
  void dispose() {
    _habitListBloc.add(ScreenDisposedEvent());
    super.dispose();
  }

  _showMessage(String message) {
    _fToast.init(context);
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.white, 
      ),
      child: Text(message),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fToast.showToast(
        child: toast,
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
    });
  }
}
