import 'package:flutter/material.dart';

class CurrentDateTime {
  static String formatedDateTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMicrosecondsSinceEpoch(int.parse(time));

    return TimeOfDay.fromDateTime(date).format(context);
  }

  static String getTime({required BuildContext context, required String time}) {
    final DateTime sent = DateTime.fromMicrosecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == now.year) {
      return TimeOfDay.fromDateTime(sent).format(context);
    } else if (now.day != sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return "${sent.day} ${getMonth(month: sent.month)}";
    } else if (now.year != sent.year) {
      return '${sent.month} ${sent.year}';
    } else {
      return 'NA';
    }
  }

  static String getMonth({required int month}) {
    switch (month) {
      case 1:
        return "jan";
      case 2:
        return "feb";
      case 3:
        return "mar";
      case 4:
        return "apr";
      case 5:
        return "may";
      case 6:
        return "jun";
      case 7:
        return "jul";
      case 8:
        return "aug";
      case 9:
        return "sept";
      case 10:
        return "oct";
      case 11:
        return "nov";
      case 12:
        return "dec";
      default:
        return 'NA';
    }
  }

  static String getDateTime(
      {required BuildContext context, required String time}) {
    final DateTime sent = DateTime.fromMicrosecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == now.year) {
      if (now.hour - sent.hour <= 1) {
        return '${now.minute - sent.minute} min ago';
      }
      if (now.hour - sent.hour > 1 && now.hour - sent.hour <= 23) {
        return '${now.hour - sent.hour} ago';
      }
    } else if (now.day != sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return "${sent.day} ${getMonth(month: sent.month)}";
    } else if (now.year != sent.year) {
      return '${sent.month} ${sent.year}';
    } else {
      return 'NA';
    }
    return 'NA';
  }
}
