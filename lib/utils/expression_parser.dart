import 'dart:collection';
import 'dart:math';

import 'package:calculator_test/utils/utils.dart';

// моя реализация алгоритма Shunting Yard 
// на вход передаем математической выражение 
// в колбеке ловим значение, или null, если его не удалось вывести
typedef OnExpressionResult = void Function(num result);

class ExpressionParser {


  static final RegExp _spaceRegExp = RegExp(r'\s+');
  static final RegExp _digitRegExp = RegExp(r'[\.0-9]+');
  static final RegExp _operatorRegExp = RegExp(r'[-*/+^()]+');
  static const String _sqrt = 'sqrt(';

  var _queue = ListQueue<dynamic>();
  // специально сделал для упрощения подсчета значений
  var _evaluator = _Evaluator();
  var _stack = ListQueue<dynamic>();
  String _mathExpression;


  /// принимает уравнение, и заменяет в нем все неизвестные на их значения
  /// а дальше использует [parseRawExpression] для вывода значения
  num parseSimpleEquation({String equationExpression, String unknownVarName = 'x', num unknownValue}) {
    var rawExpression = _replaceUnknown(
      equationExpression: equationExpression,
      unknownValue: unknownValue,
      unknownVarName: unknownVarName
    );
    // print(rawExpression);
    return parseRawExpression(rawExpression);
  }
  /// рукурентно заменяет иксы на значение. Если перед иксом идет число, то добавляется знак *
  String _replaceUnknown({String equationExpression, String unknownVarName = 'x', num unknownValue}) {
    if (!equationExpression.contains(unknownVarName)) return equationExpression;
    // грязный хак, чтобы научная запись не ломала вычисления
    // она в моем парсере не поддерживается. Дает не очень хорошую точность, но
    // достаточную для этой задачи
    var shortString = unknownValue.toStringAsFixed(8);
    var stringBuffer = StringBuffer();
    for (var i = 0; i < equationExpression.length; i++) {
      var char = equationExpression[i];
      if (char == unknownVarName) {
        if (i > 0 && isDigit(equationExpression[i - 1])) {
          stringBuffer.write('*');
          stringBuffer.write(shortString);
        } 
        else {
          stringBuffer.write(shortString);
        }
      } 
      else {
        stringBuffer.write(char);
      }
    }
    return _replaceUnknown(
      equationExpression: stringBuffer.toString(),
      unknownValue: unknownValue,
      unknownVarName: unknownVarName
    );
  }

  /// парсит выражение без неизвестных
  num parseRawExpression(String mathExpression) {
    _reset();
    _mathExpression = mathExpression;
    if (!_hasDigits()) {
      return 0;
    } else {
      if (mathExpression.contains(_sqrt)) {
        _mathExpression = _precalculateSquareRoot(mathExpression);
      }
      return _preProcess(_mathExpression);
    }
  }

  bool _hasDigits() {
    for (var i = 0; i < _mathExpression.length; i++) {
      if (isDigit(_mathExpression[i], allowPeriod: false)) {
        return true;
      }
    }
    return false;
  }

  String _precalculateSquareRoot(String expression) {
    if (expression.contains(_sqrt)) {
      var startIndex = expression.indexOf(_sqrt);
      var endIndex = -1;
      var innerExpression = StringBuffer();
      for (var i = startIndex + _sqrt.length; i < expression.length; i++) {
        if (expression[i] == ')') {
          endIndex = i;
          break;
        }
        innerExpression.write(expression[i]);
      }
      if (innerExpression.isNotEmpty) {
        var parser = ExpressionParser();
        var result = parser._preProcess(innerExpression.toString());
        var startPart = expression.substring(0, startIndex);
        var endPart = endIndex > 0 ? expression.substring(endIndex + 1, expression.length) : '';
        var value = '$startPart${sqrt(result)}$endPart';
        return value;
      }
    }
    return expression;
  }

  num _preProcess(String expression) {
    // просто чтобы снести возможные пробелы
    expression = expression.replaceAll(_spaceRegExp, '');
    var stringBuffer = StringBuffer();
    for (var i = 0; i < expression.length; i++) {
      var char = expression[i];
      if (isOperator(char)) {
        // если встретился оператор, то надо закрыть существующее число,
        // если оно уже есть и запушить его в очередь
        if (stringBuffer.isNotEmpty) {
          var number = double.parse(stringBuffer.toString());
          _queue.add(number);
          stringBuffer.clear();
        }
        

        if (char == '-') {
          if (_isNextOperatorPower(startIndex: i + 1, expression: expression)) {
            // для правильного возведения в степень негативного числа
            stringBuffer.write(char);
            if (i == expression.length -1) {
              var number = double.parse(stringBuffer.toString());
              _queue.add(number);
              stringBuffer.clear();
            }
          } else {
             _preprocessAddOperator(char);
          }
        } else {
           _preprocessAddOperator(char);
        }
          // не считаем минус отдельным оператором, а добавляем его в состав числа
          // _preprocessAddOperator(char);
        // } else {
        //   stringBuffer.write(char);
          // if (i == expression.length -1) {
          //   var number = double.parse(stringBuffer.toString());
          //   _queue.add(number);
          //   stringBuffer.clear();
          // }
        // }
          

        // } else {
        //   // если вначале стоит минус, то записываем как отрицательное число
        //   stringBuffer.write(char);
        // }
        
      } 
      else if (_isDigit(char)) {
        stringBuffer.write(char);
        if (i == expression.length -1) {
          var number = double.parse(stringBuffer.toString());
          _queue.add(number);
          stringBuffer.clear();
        }
      }
    }
    while (_stack.isNotEmpty) {
      _queue.add(_stack.removeLast());
    }

    _stack.clear();
    return _postProcess(_queue);
  }
  /// если найден минус, но следующий оператор сразу после него будет 
  /// возведение в степень, то минут нужно прикрепить к числу, а не добавлять 
  /// в стек операторов, чтобы возведение в степень произошло правильно
  bool _isNextOperatorPower({int startIndex = -1, String expression}) {
    if (startIndex >= expression.length -1) return false;
    for (var i = startIndex; i < expression.length; i++) {
      if (isOperator(expression[i])) {
        var op = expression[i];
        return op == '^';
      }
    }
    return false;
  }

  void _preprocessAddOperator(dynamic op) {
    
    if (_stack.isEmpty) {
      _stack.add(op);
    } else {
      if (op == ')') {
        while (_stack.isNotEmpty) {
          var last = _stack.removeLast();
          if (last == '(') {
            break;
          } else {
            _queue.add(last);
          }
        }
      } 
      else {
        var curPrec = _getOperatorPrecedence(op);
        var lastPrec = _getOperatorPrecedence(_stack.last);
        if (curPrec < lastPrec) {
          // если приоритет текущего оператора меньше, чем у верхнего на стеке
          // то этот верхний надо сначала попнуть и добавить в очередь
          if (_stack.last != '(') {
            _queue.add(_stack.removeLast());
          }
          _stack.add(op);
        } else {
          _stack.add(op);
        }
      }
    }
  }

  num _postProcess(ListQueue<dynamic> queue) {
    for (var i = 0; i < queue.length; i++) {
      _addToPostProcessStack(queue.elementAt(i));
    }
    return _processResult();
  }
  num _processResult() {
    if (_stack.isEmpty) {
      return _clearTrailingZeroes(_evaluator.tryGetUnaryResult()); 
    }
    return _clearTrailingZeroes(_stack.first);
  }
  // небольшой хак, чтобы не показывать на экране калькулятора мантиссу, если она равна нулю
  num _clearTrailingZeroes(num value) {
    if (value == null) return value;
    if (value.remainder(1.0) == 0.0) {
      return value.toInt();
    }
    return value;
  }
  void _reset() {
    _queue = ListQueue<dynamic>();
  // специально сделал для упрощения подсчета значений
    _evaluator = _Evaluator();
    _stack = ListQueue<dynamic>();
  }

  void _addToPostProcessStack(dynamic char) {
    
    if (_stack.isEmpty) {
      _stack.add(char);
    } else {
      if (char is! num) {
        if (_stack.last is num) {
          var last = _stack.removeLast();
          _evaluator.addSymbol(char);
          _evaluator.addSymbol(last);

          if (_evaluator.canEvaluate()) {
            _stack.add(_evaluator.evaluate());
            _evaluator.reset();
          } else {
            if (_stack.isNotEmpty && _stack.last is num) {
              last = _stack.removeLast();
              _evaluator.addSymbol(last);
              if (_evaluator.canEvaluate()) {
                _stack.add(_evaluator.evaluate());
                _evaluator.reset();
              } 
            } 
          }
        } 
        else {
          // если на стеке предыдущее значение не было числом
          // просто добавляем туда оператор
          _stack.add(char);
        }
      } else {
        _stack.add(char);
      }
    }
  }
  

  int _getOperatorPrecedence(String op) {
    switch(op) {
      // case '^':
      //   return -1;
      case '+':
      case '-':
        return 0;
      case '*':
      case '/':
        return 1;
      case '^':
        return 2;
      case '(':
      case ')':
        return 3;
    }
    return -1;
  }

  static bool isOperator(String value) {
    return _operatorRegExp.stringMatch(value) != null;
  }
  bool _isDigit(String value) {
    if (value == null || value.isEmpty) return false;
    return _digitRegExp.stringMatch(value) != null;
  }
}

class _Evaluator {
  num _first;
  num _last;
  String _operator;

  void addSymbol(dynamic symbol) {
    if (symbol is num) {
      if (_last == null) {
        _last = symbol;
      } else {
        _first = symbol;
      }
    } else {
      _operator = symbol;
    }
  }

  void reset() {
    _first = null;
    _last = null;
    _operator = null;
  }

  bool canAddNumbers() {
    return _first == null || _last == null;
  }
  bool canAddOperator() {
    return _operator == null;
  }
  // тот случай, когда выражение не могло быть полностью сформировано
  // но часть значений уже есть, например при выражении "-2"
  num tryGetUnaryResult() {
    if (_last == null) {
      return null;
    }
    if (_operator == '-') {
      return -_last;
    } 
    else if (_operator == '') {

    }
    return _last;
  }

  bool canEvaluate() {
    return _first != null && _last != null && _operator != null;
  }
  num evaluate() {
    switch (_operator) {
      case '*':
        return _first * _last;
      case '/':
        return _first / _last;
      case '+':
        return _first + _last;
      case '-':
        return _first - _last;
      case '^':
        return pow(_first, _last);
    }
    return null;
  }
}