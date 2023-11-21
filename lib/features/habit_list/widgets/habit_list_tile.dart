import 'package:auto_route/auto_route.dart';
import 'package:dt_test/features/habit_list/block/habit_list_bloc.dart';
import 'package:dt_test/data/habits/models/habit.dart';
import 'package:dt_test/data/habits/models/habit_type.dart';
import 'package:dt_test/router/router.dart';
import 'package:flutter/material.dart';

class HabitListTile extends StatelessWidget {
  const HabitListTile({
    super.key,
    required this.habit,
    required this.idx,
    required this.bloc,
  });
  final Habit habit;
  final int idx;
  final HabitListBloc bloc;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          border: Border.all(color: habit.color),
          borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        hoverColor: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          AutoRouter.of(context)
              .push(EditHabitRoute(habit: habit))
              .then((value) => bloc.add(LoadHabitsListEvent()));
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Text(habit.title,
                      style: Theme.of(context).textTheme.headlineMedium),
                  FilledButton.tonalIcon(
                      label: const Text("Выполнить"),
                      onPressed: () {
                        bloc.add(HabitCompletedEvent(
                          completedHabit: habit,
                          completedHabitIdx: idx,
                        ));
                      },
                      icon: Icon(
                        Icons.check,
                        color: habit.type == HabitType.good
                            ? Colors.green
                            : Colors.red,
                      ))
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Text(
                    "Приоритет: ${habit.priority.displayRuName}",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    "${habit.type.displayRuName} привычка",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: habit.type == HabitType.good
                            ? Colors.green
                            : Colors.red),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    "Частота: ${habit.count} раз за ${habit.frequency} дней",
                    style: Theme.of(context).textTheme.labelLarge,
                  )
                ],
              ),
              habit.description.isNotEmpty
                  ? Card(
                      elevation: 0,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ExpansionTile(
                        shape: const Border(),
                        expandedAlignment: Alignment.topLeft,
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        tilePadding: const EdgeInsets.symmetric(horizontal: 10),
                        childrenPadding: const EdgeInsets.all(10),
                        title: Text(
                          'Описание',
                          maxLines: 50,
                          overflow: TextOverflow.clip,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        children: [
                          Text(habit.description),
                        ],
                      ))
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
