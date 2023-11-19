import 'package:hive_flutter/hive_flutter.dart';

part 'habit_type.g.dart';

@HiveType(typeId: 3)
enum HabitType {
  @HiveField(0)
  good(0),
  @HiveField(1)
  bad(1);

  const HabitType(this.value);
  final num value;
  static HabitType getByValue(num i) {
    return HabitType.values.firstWhere((x) => x.value == i);
  }

  static HabitType getByRuName(String name) {
    return HabitType.values.firstWhere((x) => x.displayRuName == name);
  }

  String get displayRuName {
    switch (this) {
      case HabitType.good:
        return 'Хорошая';
      case HabitType.bad:
        return 'Плохая';
      default:
        return '';
    }
  }
}
