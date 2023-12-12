import 'package:flutter/material.dart';

class CurrentDateTime {
  static String formatedDateTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));

    return TimeOfDay.fromDateTime(date).format(context);
  }
}
