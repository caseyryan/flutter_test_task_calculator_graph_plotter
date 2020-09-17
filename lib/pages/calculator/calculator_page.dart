import 'package:calculator_test/apis/wolfram_api.dart';
import 'package:calculator_test/pages/calculator/calculator_button.dart';
import 'package:calculator_test/pages/plotter/plotter_page.dart';
import 'package:calculator_test/pages/plotter/wolfram_plot_page.dart';
import 'package:calculator_test/utils/function_scope_builder.dart';
import 'package:calculator_test/utils/utils.dart';
import 'package:flutter/material.dart';


class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {

  static const int _numCols = 4;
  
  TextEditingController _calcInputController;
  TextEditingController _minValueController;
  TextEditingController _maxValueController;
  FocusNode _minValFocusNode;
  FocusNode _maxValFocusNode;
  ThemeData _themeData;
  List<String> _buttonValues = <String>[
    'C', 'sqrt(', '^', '<',
    '(', ')', 'x', '+',
    '7', '8', '9', '/',
    '4', '5', '6', '*',
    '1', '2', '3', '-',
    '', '.', '0', 'plot',
  ]; 
  // чтобы не дать ничего делать, пока грузится ответ от вольфрама
  bool _isLoading = false;
  bool _useWolframApi = false;
  TextEditingController _selectedController;

  @override
  void initState() {
    _minValFocusNode = FocusNode();
    _maxValFocusNode = FocusNode();
    _calcInputController = TextEditingController();
    _minValueController = TextEditingController();
    _maxValueController = TextEditingController();
    _selectedController = _calcInputController;
    super.initState();
  }
  @override
  void dispose() {
    _minValFocusNode.dispose();
    _maxValFocusNode.dispose();
    _calcInputController.dispose();
    _minValueController.dispose();
    _maxValueController.dispose();
    super.dispose();
  }

  Widget _getButtons() {
    var columnChildren = <Widget>[];
    // заполняет кнопки. Количество колонок можно поменять
    // механизм от этого не сломается. 
    // Просто пересчитает количество рядов
    var numRows = _buttonValues.length ~/ _numCols;
    var buttonIndex = 0;
    outer: for (var i = 0; i < numRows; i++) {
      var rowChildren = <Widget>[];
      columnChildren.add(Row(
        children: rowChildren
      ));
      for (var j = 0; j < _numCols; j++) {
        if (buttonIndex >= _buttonValues.length) {
          break outer;
        }
        rowChildren.add(CalculatorButton(
          onPressed: _onButtonPressed,
          text: _buttonValues[buttonIndex],
        ));
        buttonIndex++;
      }
    }

    return Column(
      children: columnChildren,
    );
  }
  void _onButtonPressed(String value) {
    if (_isLoading) return;

    if (value == 'plot') {
      _plotFunction();
      return;
    } 
    else if (value.toLowerCase() == 'c') {
      _clear();
    }
    else if (value == '<') {
      _removeLastSymbol();
    }
    else {
      _selectedController.text += value;
    }
  }

  Future _plotFunction() async {
    if (_isLoading) return;
    var minValue = double.tryParse(_minValueController.text);
    var maxValue = double.tryParse(_maxValueController.text);
    if (minValue == null || maxValue == null) {
      showAlert('Не указан диапазон функции', context);
      return;
    } 
    else if (minValue - maxValue == 0) {
      showAlert(
        'Слишком маленький диапазон функции', 
        context
      );
      return;
    }
    else if (minValue > maxValue) {
      showAlert(
        'Минимальное значение должно быть больше максимального', 
        context
      );
      return;
    }
    if (_calcInputController.text.isEmpty) {
      showAlert(
        'Не заполнено поле функции', 
        context
      );
      return;
    }
    if (_useWolframApi) {
      setState(() {
        _isLoading = true;
      });
      var imageUrl = await WolframApi.plotAFunction(
        expression: _calcInputController.text,
        fromX: minValue,
        toX: maxValue
      );
      if (imageUrl == null) {
        showAlert('Не удалось произвести расчет', context);
      }
      else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return WolframPlotPage(
                imageUrl: imageUrl,
              );
            },
            fullscreenDialog: true
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });

    } else {
      var points = FunctionScopeBuilder.buildPointsForYofX(
        equation: _calcInputController.text,
        pointsToAddBetween: 60.0,
        xMax: maxValue,
        xMin: minValue
      );
      print(points);
      /// чтобы вписать функцию в определенный прямоугольник
      /// получаем минимальное и максимальное значение по вертикали
      var yDimentions = FunctionScopeBuilder.getCanvasVertivalDimentions(points);

      if (yDimentions == null) {
        showAlert(
          'Недостаточно данных', 
          context
        );
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return PlotterPage(
              verticalDimentions: yDimentions,
              horizontalDimentions: Offset(minValue, maxValue),
              points: points,
            );
          },
          fullscreenDialog: true
        ),
      );
    }
  }

  void _removeLastSymbol() {
    var curText = _selectedController.text;
    if (curText.isNotEmpty) {
      _selectedController.text = curText.substring(0, curText.length - 1);
    }
  }
  void _clear() {
     _selectedController.clear();
  }

  Widget _getCalcTypeSwitch() {
    return SwitchListTile(
      title: Text('Использовать Wolfram Alpha API', 
        style: _themeData.textTheme.body2,
      ),
      value: _useWolframApi,
      onChanged:(bool newValue) async {
        setState(() {
          _useWolframApi = !_useWolframApi;
        });
      },
    );
  }

  Widget _getInput({
    TextEditingController controller, 
    bool readOnly = true,
    String hintText = '',
    FocusNode focusNode,
    FocusNode nextFocusNode,
    VoidCallback onDone
    }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedController = controller;
        });
      },
      child: AbsorbPointer(
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: _selectedController == controller 
                ? Colors.green[100]
                : Colors.white,
              border: Border.all(
                color: _themeData.accentColor,
                width: 2.0,
                style: BorderStyle.solid
              ),
              borderRadius: BorderRadius.circular(5)
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                focusNode: focusNode,
                textAlign: TextAlign.center,
                style: _themeData.textTheme.headline,
                readOnly: readOnly,
                keyboardType: TextInputType.number,
                textInputAction: nextFocusNode != null 
                  ? TextInputAction.next
                  : TextInputAction.done,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: _themeData.textTheme.body2.copyWith(color: Colors.black38)
                ),
                onSubmitted: (String value) {
                  if (nextFocusNode != null) {
                    FocusScope.of(context).requestFocus(nextFocusNode);
                  } else {
                    if (onDone != null) onDone();
                  }
                },
                controller: controller,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Super Calculator'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Text('Укажите диапазон функции y(x)', 
                  style: _themeData.textTheme.body2,
                ),
                Row(
                  children: <Widget>[
                    Flexible(child: _getInput(
                      readOnly: true,
                      hintText: 'Мин', 
                      controller: _minValueController, 
                      focusNode: _minValFocusNode,
                      nextFocusNode: _maxValFocusNode
                    )),
                    Flexible(child: _getInput(
                      readOnly: true,
                      hintText: 'Макс',
                      controller: _maxValueController,
                      focusNode: _maxValFocusNode,
                      nextFocusNode: null,
                      onDone: _plotFunction
                    )),
                  ],
                ),
                _getInput(
                  controller: _calcInputController, 
                  readOnly: true,
                  hintText: 'Функция, например x^2 + 2x'
                ),
                Container(
                  height: 3.0,
                  child: _isLoading 
                    ? LinearProgressIndicator() 
                    : Container(),
                ),
                SizedBox(height: 15.0),
                _getCalcTypeSwitch(),
                _getButtons()
              ],
            ),
          ),
        ),
      ),
    );
  }
}