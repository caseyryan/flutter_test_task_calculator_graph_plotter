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

  List<Widget> _getPlotPointViews(ThemeData themeData) {
    var results = <Widget>[];
    for (var i = 0; i < points.length; i++) {
      results.add(
        Card(
          child: Container(
            color: Colors.white,
            height: 50,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Text('${i + 1}.'),
                  Expanded(
                    child: Center(
                      child: Text(
                        'x: ${points[i].dx.toStringAsFixed(2)}, y: ${points[i].dy.toStringAsFixed(2)}',
                        style: themeData.textTheme.headline
                      ),
                    )
                  ),
                ],
              ),
            ),
          ),
        )
      );
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Plotter'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (c, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
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
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Точки графика'),
                  ),
                  ..._getPlotPointViews(themeData)
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}