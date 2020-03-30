import 'dart:math';

import 'package:calculator_test/utils/expression_parser.dart';
import 'package:flutter/widgets.dart';

class FunctionScopeBuilder {

  static ExpressionParser _expressionParser = ExpressionParser(); 

  /// высчитывает точки на основе диапазона функции и уравнения
  static List<Offset> buildPointsForYofX({
      num xMin, 
      num xMax, 
      String equation, 
      double pointsToAddBetween = 10.0
    }) {
    assert(xMax != null && xMin != null);
    assert(xMin < xMax);
    assert(xMax - xMin != 0);
    assert(equation != null && equation.isNotEmpty);
    var step = (xMax - xMin) / pointsToAddBetween;
    var result = <Offset>[];
    var x = xMin;
    for (var i = 0; i <= pointsToAddBetween; i++) {
      var y = _expressionParser.parseSimpleEquation(
        equationExpression: equation,
        unknownValue: x,
        unknownVarName: 'x',
      );
      var point = Offset(x.toDouble(), y.toDouble());
      // print(point);
      result.add(point);
      x += step;
    }
    return result;
  } 

  /// возвращает минимальное и максимальной значение y, чтобы уместить 
  /// на экране. dx содержит минимальное значение, dy масимальное
  static Offset getCanvasVertivalDimentions(List<Offset> points) {
    if (points == null || points.length < 2) return null;
    var yVals = points.map((v) => v.dy);
    var yMax = yVals.reduce(max);
    var yMin = yVals.reduce(min);
    return Offset(yMin, yMax);
  }

}