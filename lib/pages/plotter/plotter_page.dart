import 'package:calculator_test/utils/plot_painter.dart';
import 'package:flutter/material.dart';

class PlotterPage extends StatelessWidget {

  final Offset verticalDimentions;
  final Offset horizontalDimentions;
  final List<Offset> points;

  const PlotterPage({
    Key key, 
    this.verticalDimentions, 
    this.points,
    this.horizontalDimentions
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plotter'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (c, BoxConstraints constraints) {
            return Container(
              width: constraints.biggest.width,
              height: constraints.biggest.height,
              color: Colors.white,
              child: CustomPaint(
                painter: PlotPainter(
                  points: points,
                  verticalDimentions: verticalDimentions,
                  horizontalDimentions: horizontalDimentions
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}