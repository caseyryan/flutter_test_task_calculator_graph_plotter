import 'package:flutter/material.dart';

class WolframPlotPage extends StatelessWidget {

  final String imageUrl;

  const WolframPlotPage({
    Key key, 
    this.imageUrl
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Wolfram Plot Page'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            width: double.infinity,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}