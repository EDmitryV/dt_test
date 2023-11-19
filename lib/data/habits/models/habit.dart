import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:dt_test/data/habits/models/done_date.dart';
import 'package:dt_test/data/habits/models/habit_priority.dart';
import 'package:dt_test/data/habits/models/habit_status.dart';
import 'package:dt_test/data/habits/models/habit_type.dart';

part 'habit.g.dart';

@HiveType(typeId: 4)
class Habit 
 extends HiveObject
{
  @HiveField(0)
  String uid; //Используется только в заголовках API
  @HiveField(1)
  Color color;
  @HiveField(2)
  int count;
  @HiveField(3)
  int date;
  @HiveField(4)
  String description;
  @HiveField(5)
  int frequency;
  @HiveField(6)
  HabitPriority priority;
  @HiveField(7)
  String title;
  @HiveField(8)
  HabitType type;
  @HiveField(9)
  List<DoneDate> doneDates;
  @HiveField(10)
  bool doneDatesSynchronized;
  @HiveField(11)
  HabitStatus status; //Используется для выявления необходимости синхронизации
  Habit(
      {this.uid = "",
      this.color = Colors.white,
      this.count = 1,
      required this.date,
      this.description = "",
      this.frequency = 1,
      this.priority = HabitPriority.medium,
      this.title = "",
      this.type = HabitType.good,
      this.doneDates = const [],
      this.doneDatesSynchronized = true,
      this.status = HabitStatus.normal});

  Habit copyParamsFrom({required Habit habit}) {
    uid = habit.uid;
    color = habit.color;
    count = habit.count;
    date = habit.date;
    description = habit.description;
    frequency = habit.frequency;
    priority = habit.priority;
    title = habit.title;
    type = habit.type;
    doneDates = habit.doneDates;
    doneDatesSynchronized = habit.doneDatesSynchronized;
    status = habit.status;
    return this;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'color': color.value,
      'count': count,
      'date': date,
      'description': description,
      'frequency': frequency,
      'priority': priority.value,
      'title': title,
      'type': type.value,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      uid: map['uid'] as String,
      color: Color(map['color'] as int),
      count: map['count'] as int,
      date: map['date'] as int,
      description: map['description'] as String,
      frequency: map['frequency'] as int,
      priority: HabitPriority.getByValue(map['priority'] as int),
      title: map['title'] as String,
      type: HabitType.getByValue(map['type'] as int),
      doneDates: map['doneDates'] != null
          ? List<DoneDate>.from(
              (map['doneDates'] as List<int>).map<DoneDate>(
                (x) => DoneDate.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory Habit.fromJson(String source) =>
      Habit.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Habit(uid: $uid, color: $color, count: $count, date: $date, description: $description, frequency: $frequency, priority: $priority, title: $title, type: $type, doneDates: $doneDates, status: $status)';
  }

  @override
  bool operator ==(covariant Habit other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.color == color &&
        other.count == count &&
        other.date == date &&
        other.description == description &&
        other.frequency == frequency &&
        other.priority == priority &&
        other.title == title &&
        other.type == type &&
        listEquals(other.doneDates, doneDates) &&
        other.doneDatesSynchronized == doneDatesSynchronized &&
        other.status == status;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        color.hashCode ^
        count.hashCode ^
        date.hashCode ^
        description.hashCode ^
        frequency.hashCode ^
        priority.hashCode ^
        title.hashCode ^
        type.hashCode ^
        doneDates.hashCode ^
        doneDatesSynchronized.hashCode ^
        status.hashCode;
  }
}
