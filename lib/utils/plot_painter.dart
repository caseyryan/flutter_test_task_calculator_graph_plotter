import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlotPainter extends CustomPainter {

  final Offset verticalDimentions;
  final Offset horizontalDimentions;
  final List<Offset> points;

  Paint _strokePaint;
  Paint _gridPaint;
  TextStyle _textStyle;
  double _verticalStep;
  double _horizontalStep;
  double _padding = 50.0;


  PlotPainter({
    this.points,
    this.verticalDimentions,
    this.horizontalDimentions
  });

  @override
  void paint(Canvas canvas, Size size) {
    
    _strokePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    _gridPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    _textStyle = TextStyle(
      color: Colors.black,
      fontSize: 12,
    );

    _verticalStep = ((size.height - _padding * 2) / (verticalDimentions.dy - verticalDimentions.dx));
    _horizontalStep = ((size.width - _padding * 2) / (horizontalDimentions.dy - horizontalDimentions.dx));

    // рисование самой функции
    var path = Path();
    var squeezedHeight = size.height - _padding;
    var point0 = _pointToScreenPoint(points[0], squeezedHeight);
    path.moveTo(point0.dx, point0.dy);
    
    for (var i = 1; i < points.length; i++) {
      var point = _pointToScreenPoint(points[i], squeezedHeight);
      path.lineTo(point.dx, point.dy);

      // if (i % 10 == 0) {
      //   var ySpan = TextSpan(
      //     text: points[i].dy.toStringAsFixed(1),
      //     style: _textStyle,
      //   );
      //   var textPainter = TextPainter(
      //     text: ySpan,
      //     textDirection: TextDirection.ltr,
      //   );
      //   textPainter.layout(
      //     minWidth: 0,
      //     maxWidth: size.width,
      //   );
      //   var offset = Offset(0, (_verticalStep * i) + squeezedHeight);
      //   textPainter.paint(canvas, offset);
      // }
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