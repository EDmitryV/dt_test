import 'package:hive_flutter/hive_flutter.dart';

part 'habit_status.g.dart';

@HiveType(typeId: 2)
enum HabitStatus {
  @HiveField(0)
  deleted,
  @HiveField(1)
  created,
  @HiveField(2)
  updated,
  @HiveField(3)
  synchronized,
  @HiveField(4)
  normal;
}
