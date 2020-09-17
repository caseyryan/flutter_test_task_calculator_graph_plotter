import 'package:calculator_test/utils/expression_parser.dart';
import 'package:flutter_test/flutter_test.dart';

ExpressionParser _parser = ExpressionParser();

void main() {
  test('calculate expression', () {
    expect(_testExpression('x+3^x', 2), 11);
    expect(_testExpression('2^x', -2), 0.25);
    expect(_testExpression('2^x', 2), 4);
    expect(_testExpression('2*-5^2-10', 2), 40);
    expect(_testExpression('3x^2', 2), 12);
    expect(_testExpression('3x^2', 3), 27);
    expect(_testExpression('-2^2+6^2', 2), 40);
    expect(_testExpression('sqrt(25)^2', 2), 25);
  });
}

dynamic _testExpression(String expression, double xValue) {
  var value =_parser.parseSimpleEquation(
    equationExpression: expression,
    unknownValue: xValue,
  );
  return value;
}