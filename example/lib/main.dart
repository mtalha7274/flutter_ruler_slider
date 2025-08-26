import 'package:flutter/material.dart';
import 'package:flutter_ruler/flutter_ruler_slider.dart';

void main() => runApp(const RulerExample());

class RulerExample extends StatefulWidget {
  const RulerExample({super.key});

  @override
  State<RulerExample> createState() => _RulerExampleState();
}

class _RulerExampleState extends State<RulerExample> {
  double _value = 36;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FlutterRulerSlider(
                minValue: 20,
                maxValue: 100,
                initialValue: 36,
                width: 300,
                interval: 10,
                smallerInterval: 10,
                snapping: true,
                showLabels: true,
                showSubLabels: false,
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
                onValueChanged: (v) {
                  setState(() => _value = v);
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Selected: ${_value.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
