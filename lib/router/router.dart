import 'package:auto_route/auto_route.dart';
import 'package:dt_test/features/edit_habit/view/edit_habit_screen.dart';
import 'package:dt_test/features/habit_list/view/habit_list_screen.dart';
import 'package:dt_test/data/habits/models/habit.dart';
import 'package:flutter/material.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HabitListRoute.page, path: '/'),
    AutoRoute(page: EditHabitRoute.page)
      ];
}
