import 'package:calculator_test/utils/utils.dart';
import 'package:flutter/material.dart';

class CalculatorButton extends StatelessWidget {

  final String text;
  final ValueChanged<String> onPressed;

  const CalculatorButton({
    Key key, 
    this.text, 
    this.onPressed
  }) : 
    assert(text != null), 
    assert(onPressed != null), 
    super(key: key);

  /// просто для того, чтобы как-то выделить числовые кнопки и равно
  Color _getColorByTextType(String text, ThemeData themeData) {
    if (text == 'plot') {
      return Colors.orange;
    } 
    else if (isDigit(text)) {
      return Colors.green;
    }
    return themeData.accentColor;
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: FlatButton(
          color: _getColorByTextType(text, themeData),
          onPressed: text.isEmpty ? () {} : () {
            onPressed(text);
          },
          child: Container(
            width: 100,
            height: 80,
            child: Center(
              child: Text(
                text,
                style: themeData.textTheme.headline
                  .copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}