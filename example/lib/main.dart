import 'package:flutter/material.dart';
import 'package:flutter_ruler/flutter_ruler.dart';

void main() => runApp(const RulerExample());

class RulerExample extends StatelessWidget {
  const RulerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: FlutterRuler(
            minValue: 20,
            maxValue: 100,
            initialValue: 36,
            width: 300,
            interval: 10,
            smallerInterval: 10,
            snapping: true,
            showLabels: true,
            showSubLabels: true,
            labelSpacing: 6,
            labelRotation: 0,
            tickStyle: const RulerTickStyle(
              majorHeight: 30,
              minorHeight: 15,
              majorThickness: 2,
              minorThickness: 1,
              majorColor: Colors.black,
              minorColor: Colors.black,
            ),
            onValueChanged: (v) =>
                debugPrint('Center value: ${v.toStringAsFixed(1)}'),
          ),
        ),
      ),
    );
  }
}
