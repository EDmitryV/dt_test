import 'dart:math';

class DateIntConverter {
  int parseNumFromDate(DateTime dateTime) {
    return int.parse(dateTime.year.toString() +
        _getTwoDigits(dateTime.month) +
        _getTwoDigits(dateTime.day) +
        _getTwoDigits(dateTime.hour) +
        _getTwoDigits(dateTime.minute) +
        _getTwoDigits(dateTime.second));
  }

  String _getTwoDigits(int num) {
    return (num + 100).toString().substring(1);
  }

  DateTime parseDateFromNum(int date) {
    List<int> dateTime = [];
    for (var i = 0; i < 6; i++) {
      var dt = date ~/ pow(10, (10 - i * 2));
      if (i > 0) dt = dt % 100;
      dateTime.add(dt);
    }
    return DateTime(
      dateTime[0],
      dateTime[1],
      dateTime[2],
      dateTime[3],
      dateTime[4],
      dateTime[5],
    );
  }
}
