import 'package:calculator_test/utils/expression_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculate expression', () {
    expect(_testExpression('2+2'), 4);
    expect(_testExpression('2+(2*2)'), 6);
    expect(_testExpression('3^2'), 9);
    expect(_testExpression('3^2+1'), 10);
    expect(_testExpression('-2'), -2); // Urinary minus test
  });
}

dynamic _testExpression(String expression) {
  num value;
  // ExpressionParser(
  //   mathExpression: expression,
  //   onExpressionResult: (num result) {
  //     value = result;
  //   }
  // );
  return value;
}