import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlotPainter extends CustomPainter {

  final Offset verticalDimentions;
  final Offset horizontalDimentions;
  final List<Offset> points;

  Paint _strokePaint;
  Paint _gridPaint;
  Paint _axisPaint;
  TextStyle _textStyle;
  double _verticalStep;
  double _horizontalStep;
  double _padding = 50.0;


  PlotPainter({
    this.points,
    this.verticalDimentions,
    this.horizontalDimentions
  });
  /// в зависимости от того, на сколько большое число точек нужно отрисовать
  /// выдает число точек, которое нужно пропускать при каждой итерации
  /// во время отрисовки грида
  int _countNumCellsToSkeep(int numSteps) {
    var len = numSteps.toString().length;
    if (len < 3) return 1; 
    var zeroes = List<String>.filled(len - 2, '0').join();
    return int.parse('1$zeroes');
  }

  @override
  void paint(Canvas canvas, Size size) {
    
    _strokePaint = Paint()
      ..color = Colors.purple
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    _gridPaint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    _axisPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    _textStyle = TextStyle(
      color: Colors.black,
      fontSize: 12,
    );

    var vSteps = (verticalDimentions.dy - verticalDimentions.dx).toInt();
    var hSteps = (horizontalDimentions.dy - horizontalDimentions.dx).toInt();
    _verticalStep = ((size.height - _padding * 2) / vSteps);
    _horizontalStep = ((size.width - _padding * 2) / hSteps);
    var squeezedHeight = size.height - _padding;

    var skipCellsH = _countNumCellsToSkeep(hSteps);
    var skipCellsV = _countNumCellsToSkeep(vSteps);

    var cellWidth = (size.width - _padding * 2)  / hSteps;
    var cellHeight = (size.height - _padding * 2) / vSteps;
    
    
    var path = Path();
    var axisPath = Path();
    
    var valueX = horizontalDimentions.dx;
    // var startValueY = roundToNearest(verticalDimentions.dx.toInt(), roundTo: skipCellsV);
    var valueY = verticalDimentions.dx;

    for (var i = 0; i <= hSteps; i+= skipCellsH) {
      var xPos = (i * cellWidth);
      path.moveTo(xPos + _padding, _padding);
      path.lineTo(xPos + _padding, size.height - _padding);

      // координаты Х
      var textSpan = TextSpan(
        text: valueX.toStringAsFixed(1),
        style: _textStyle,
      );


      if (i < hSteps + skipCellsH) {
        // отрисовка оси Y в нулевой позиции
        var nextX = valueX + skipCellsH;
        if (valueX <= 0 && nextX > 0) {
          var offset = (valueX == 0.0 ? valueX : valueX / nextX).abs(); 
          var lineX = _padding + xPos + (cellWidth * skipCellsH) * offset;

          // lineX += (cellWidth * skipCellsH) * offset;
          axisPath.moveTo(lineX, _padding);
          axisPath.lineTo(lineX, size.height - _padding);
          canvas.drawPath(axisPath, _axisPaint);
        }
      }
      valueX += skipCellsH;

      var textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      // позиция текста по оси Х
      var offset = Offset((xPos - cellWidth / 2) + _padding, size.height - _padding + 10);
      textPainter.paint(canvas, offset);

    }
    canvas.drawPath(path, _gridPaint);

    for (var i = 0; i <= vSteps; i+= skipCellsV) {
      var yPos = (i * cellHeight);
      path.moveTo(_padding, yPos + _padding);
      path.lineTo(size.width - _padding, yPos + _padding);

      var textSpan = TextSpan(
        text: valueY.toStringAsFixed(1),
        style: _textStyle,
      );
      
      
      if (i < vSteps + skipCellsV) {
        // отрисовка оси X в нулевой позиции
        var nextY = valueY + skipCellsV;
        if (valueY <= 0 && nextY > 0) {
          var offset = valueY == 0.0 ? valueY : nextY / valueY; 
          var lineY = (size.height - yPos) - _padding - (cellHeight * skipCellsV);
          lineY += (cellHeight * skipCellsV) * (1 + offset);
          axisPath.moveTo(_padding, lineY);
          axisPath.lineTo(size.width - _padding, lineY);
          canvas.drawPath(axisPath, _axisPaint);
        }
      }
      valueY += skipCellsV;

      var textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      // позиция текста по оси Х
      var offset = Offset(10, size.height - yPos - _padding);
      textPainter.paint(canvas, offset);
    }
    canvas.drawPath(path, _gridPaint);

    // рисование самой функции
    path = Path();
    var point0 = _pointToScreenPoint(points[0], squeezedHeight);
    path.moveTo(point0.dx, point0.dy);
    
    for (var i = 1; i < points.length; i++) {
      var point = _pointToScreenPoint(points[i], squeezedHeight);
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, _strokePaint);
  }

  Offset _pointToScreenPoint(Offset point, double height) {
    return Offset(
      ((point.dx - horizontalDimentions.dx) * _horizontalStep) + _padding,
      (((point.dy - verticalDimentions.dx) * _verticalStep) * -1) + height // чтобы перевернуть декартову систему
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

}