import 'package:hive_flutter/hive_flutter.dart';

part 'habit_priority.g.dart';

@HiveType(typeId: 1)
enum HabitPriority {
  @HiveField(0)
  low(0),
  @HiveField(1)
  medium(1),
  @HiveField(2)
  high(2);

  const HabitPriority(this.value);
  final int value;
  static HabitPriority getByValue(int i) {
    return HabitPriority.values.firstWhere((x) => x.value == i);
  }

  static HabitPriority getByRuName(String name) {
    return HabitPriority.values.firstWhere((x) => x.displayRuName == name);
  }

  String get displayRuName {
    switch (this) {
      case HabitPriority.low:
        return 'Низкий';
      case HabitPriority.medium:
        return 'Средний';
      case HabitPriority.high:
        return 'Высокий';
      default:
        return '';
    }
  }
}
