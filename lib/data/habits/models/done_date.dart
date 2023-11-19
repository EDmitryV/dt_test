import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

part 'done_date.g.dart';

@HiveType(typeId: 5)
class DoneDate extends HiveObject{
  @HiveField(0)
  final int date;
  @HiveField(1)
  final bool synchronized;
  @HiveType(typeId: 5)
  DoneDate({
    required this.date,
    required this.synchronized,
  });

  DoneDate copyWith({
    int? date,
    bool? synchronized,
  }) {
    return DoneDate(
      date: date ?? this.date,
      synchronized: synchronized ?? this.synchronized,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date,
      'synchronized': synchronized,
    };
  }

  factory DoneDate.fromMap(Map<String, dynamic> map) {
    return DoneDate(
      date: map['date'] as int,
      synchronized: map['synchronized'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory DoneDate.fromJson(String source) =>
      DoneDate.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'DateOfCompletion(date: $date, synchronized: $synchronized)';

  @override
  bool operator ==(covariant DoneDate other) {
    if (identical(this, other)) return true;

    return other.date == date && other.synchronized == synchronized;
  }

  @override
  int get hashCode => date.hashCode ^ synchronized.hashCode;
}
