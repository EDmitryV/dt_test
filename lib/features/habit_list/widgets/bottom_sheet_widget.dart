import 'package:dt_test/features/habit_list/block/habit_list_bloc.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class BottomSheetWidget extends StatelessWidget {
  const BottomSheetWidget(
      {super.key,
      required this.orderByDate,
      required this.orderAsc,
      required this.titlePart, required this.bloc, required this.state});
  final bool orderByDate;
  final bool orderAsc;
  final String titlePart;
  final HabitListBloc bloc;
  final ListContainingState state;

  @override
  Widget build(BuildContext context) {
    Widget dateSortIconButton;
    if (!orderByDate) {
      dateSortIconButton = IconButton(
          onPressed: () {
            bloc
                .add(ChangeDateSortEvent(orderByDate: true, orderAsc: true));
          },
          icon: const Icon(Icons.sort));
    } else {
      if (orderAsc) {
        dateSortIconButton = IconButton.filled(
            onPressed: () {
              bloc
                  .add(ChangeDateSortEvent(orderByDate: true, orderAsc: false));
            },
            icon: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationX(math.pi),
              child: const Icon(
                Icons.sort,
              ),
            ));
      } else {
        dateSortIconButton = IconButton.filled(
            onPressed: () {
             bloc
                  .add(ChangeDateSortEvent(orderByDate: false, orderAsc: true));
            },
            icon: const Icon(Icons.sort));
      }
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              onChanged: (value) {
                bloc
                    .add(ChangeTitleFilterEvent(titleFilter: value));
              },
              decoration: const InputDecoration(labelText: "Поиск по названию"),
            ),
            const SizedBox(height: 8,),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Сортировать по дате: "),
                dateSortIconButton
              ],
            )
          ]),
    );
  }
}
