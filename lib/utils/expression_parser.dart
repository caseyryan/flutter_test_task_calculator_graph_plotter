import 'dart:collection';
import 'dart:math';

// моя реализация алгоритма Shunting Yard 
// на вход передаем математической выражение 
// в колбеке ловим значение, или null, если его не удалось вывести
typedef OnExpressionResult = void Function(num result);

class ExpressionParser {

  static final RegExp _spaceRegExp = RegExp(r'\s+');
  static final RegExp _digitRegExp = RegExp(r'[\.0-9]+');
  final RegExp _digitWithoutPeriodRegex = RegExp(r'[0-9]+');
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
    print(rawExpression);
    return parseRawExpression(rawExpression);
  }
  /// рукурентно заменяет иксы на значение. Если перед иксом идет число, то добавляется знак *
  String _replaceUnknown({String equationExpression, String unknownVarName = 'x', num unknownValue}) {
    if (!equationExpression.contains(unknownVarName)) return equationExpression;
    // грязный хак, чтобы научная запись не ломала вычисления
    // она в моем парсере не поддерживается. Дает не очень хорошую точность, но
    // достаточную для этой задачи
    var shortString = double.parse(unknownValue.toStringAsFixed(8));
    var stringBuffer = StringBuffer();
    for (var i = 0; i < equationExpression.length; i++) {
      var char = equationExpression[i];
      if (char == unknownVarName) {
        if (i > 0 && _isDigit(equationExpression[i - 1])) {
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
      if (_mathExpression.contains(_sqrt)) {
        _mathExpression = _precalculateSquareRoot(_mathExpression);
      }
      if (_mathExpression.contains('^')) {
        _mathExpression = _precalculatePower(_mathExpression);
      }
      
      return _preProcess(_mathExpression);
    }
  }

  bool _hasDigits() {
    for (var i = 0; i < _mathExpression.length; i++) {
      if (_isDigit(_mathExpression[i], allowPeriod: false)) {
        return true;
      }
    }
    return false;
  }
  /// предварительно делает все возведения в степень
  /// чтобы упростить дальнейшие вычисления
  String _precalculatePower(String expression) {
    // print('INPUT EXPRESSION $expression');
    if (expression.contains('^')) {
      /// раздвигаем диапазон от положения ^ и ищем где выражение возведения
      /// в степенть начинается и заканчивается
      
      var powIndex = expression.indexOf('^');
      if (powIndex > -1) {
        // var i = expression.length;
        var startIndex = powIndex - 1;
        var endIndex = powIndex + 1;
        var startFound = false;
        var endFound = false;
        for (var i = powIndex -1; i >= 0; i--) {
          var char = expression[i];
          if (isOperator(char)) {
            if (char == '-') {
              startIndex = i;
              startFound = true;
            }
            else {
              startIndex = i + 1;
              startFound = true;
            }
            break;
          }
        }
        for (var i = powIndex +1; i < expression.length; i++) {
          var char = expression[i];
          if (isOperator(char)) {
            if (i > 0) {
              var prevChar = expression[i - 1];
              if (prevChar != '^') {
                endFound = true;
                endIndex = i;
                break;
              }
            } else {
              endFound = true;
              endIndex = i;
              break;
            }
          }
        }

        print('START $startIndex END $endIndex');
        if (startFound && endFound) {
          var innerExpression = expression.substring(startIndex, endIndex);
          if (innerExpression.isNotEmpty) {
            var parser = ExpressionParser();
            var result = parser._preProcess(innerExpression.toString());
            var startPart = expression.substring(0, startIndex);
            var endPart = endIndex > 0 ? expression.substring(endIndex, expression.length) : '';
            var value = '$startPart${result}$endPart';
            print('VLUE>>>>>>>> $value');
            value = _precalculatePower(value);
            return value;
          }
        }
      }
    }
    return expression;
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
          if (_isUnaryMinus(startIndex: i + 1, expression: expression)) {
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
  
  bool _isUnaryMinus({int startIndex = -1, String expression}) {
    if (startIndex >= expression.length -1) return false;
    for (var i = startIndex; i < expression.length; i++) {
      if (_isDigit(expression[i])) {
        return !_hasHigherPrecedenceOperatorNear(startIndex: i + 1, expression: expression);
      } 
      else if (expression[i] == '(') {
        return false;
      }
    }
    return false;
  }
  bool _hasHigherPrecedenceOperatorNear({int startIndex = -1, String expression}) {
    if (startIndex >= 3) {
      var prevChar = expression[startIndex - 3];
      if (prevChar == '^') {
        // чтобы разрешить возведение в отицательную степень
        return false;
      }
    }

    if (startIndex > expression.length -1) {
      return true;
    }
    for (var i = startIndex; i < expression.length; i++) {
      var ex = expression[i];
      if (isOperator(expression[i])) {
        return ex == '*' || ex == '/';
      }
    }
    return true;
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
      // print('STACK $_stack');
      // print('QUEUE $_queue');
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
        // добавление оператора
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
    print(_stack);


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
  bool _isDigit(String char, {bool allowPeriod = true}) {
    if (char == null || char.isEmpty || char.length > 1) {
    return false;
    } 
    var regExp = allowPeriod ? _digitRegExp : _digitWithoutPeriodRegex;
    return regExp.stringMatch(char) != null;
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