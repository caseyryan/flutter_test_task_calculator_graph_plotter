import 'package:calculator_test/pages/calculator/calculator_page.dart';
import 'package:flutter/material.dart';
import 'package:screen/screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    Screen.keepOn(true); 
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: CalculatorPage(),
    );
  }
}

