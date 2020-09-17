import 'package:flutter/material.dart';

final RegExp _digitRegex = RegExp(r'[\.0-9]+');
final RegExp _digitWithoutPeriodRegex = RegExp(r'[0-9]+');

bool isDigit(String char, {bool allowPeriod = true}) {
  if (char == null || char.isEmpty || char.length > 1) {
    return false;
  } 
  var regExp = allowPeriod ? _digitRegex : _digitWithoutPeriodRegex;
  return regExp.stringMatch(char) != null;
}

num clearTrailingZeroes(num value) {
  if (value == null) return value;
  if (value.remainder(1.0) == 0.0) {
    return value.toInt();
  }
  return value;
}
int roundToNearest(int value, {int roundTo = 5}) {
  return ((value.toDouble() / roundTo).round() * roundTo).toInt();
}
String toNumericString(String inputString, {bool allowPeriod = false}) {
  if (inputString == null) return '';
  var regExp = allowPeriod ? _digitRegex : _digitWithoutPeriodRegex;
  return inputString.splitMapJoin(regExp,
      onMatch: (m) => m.group(0),
      onNonMatch: (nm) => ''
  );
}
Future<void> showAlert(String text, BuildContext context, {String headerText = ''}) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(headerText),
        content: Text(
          text,
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text('Okay'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


