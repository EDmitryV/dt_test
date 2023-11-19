// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    EditHabitRoute.name: (routeData) {
      final args = routeData.argsAs<EditHabitRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: EditHabitScreen(
          key: args.key,
          habit: args.habit,
        ),
      );
    },
    HabitListRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HabitListScreen(),
      );
    },
  };
}

/// generated route for
/// [EditHabitScreen]
class EditHabitRoute extends PageRouteInfo<EditHabitRouteArgs> {
  EditHabitRoute({
    Key? key,
    required Habit? habit,
    List<PageRouteInfo>? children,
  }) : super(
          EditHabitRoute.name,
          args: EditHabitRouteArgs(
            key: key,
            habit: habit,
          ),
          initialChildren: children,
        );

  static const String name = 'EditHabitRoute';

  static const PageInfo<EditHabitRouteArgs> page =
      PageInfo<EditHabitRouteArgs>(name);
}

class EditHabitRouteArgs {
  const EditHabitRouteArgs({
    this.key,
    required this.habit,
  });

  final Key? key;

  final Habit? habit;

  @override
  String toString() {
    return 'EditHabitRouteArgs{key: $key, habit: $habit}';
  }
}

/// generated route for
/// [HabitListScreen]
class HabitListRoute extends PageRouteInfo<void> {
  const HabitListRoute({List<PageRouteInfo>? children})
      : super(
          HabitListRoute.name,
          initialChildren: children,
        );

  static const String name = 'HabitListRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
