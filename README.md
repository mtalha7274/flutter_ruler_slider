## flutter_ruler_slider

A highly customizable, horizontally scrollable ruler slider for Flutter. Drag freely and optionally snap to the nearest tick. Supports major/minor ticks, aligned labels (with rotation and spacing), and full tick styling (heights, thickness, and colors).

### Demo
<p align="center">
  <img src="https://s14.gifyu.com/images/bNPMW.gif" alt="Demo GIF" />
</p>

### Install
Run:

```
flutter pub add flutter_ruler_slider
```

### Usage (see full example in `example/`)
Basic setup with labels, snapping, and custom tick styling:

```dart
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
  onValueChanged: (value) {
    // handle updates
  },
)
```

### Matched ticks (0.0.2)
Highlight specific ticks by value using `matchValues`. Matched ticks use `RulerTickStyle.matchHeight`, `matchThickness`, and `matchColor` (defaults: 15.0, 1.2, transparent).

Example: highlight midpoints between major ticks in the example app:

```dart
List<int> _computeMidpoints({
  required int minValue,
  required int maxValue,
  required int interval,
}) {
  final List<int> results = <int>[];
  int start = minValue;
  while (start + interval <= maxValue) {
    final int end = start + interval;
    final int mid = ((start + end) / 2).round();
    if (mid >= minValue && mid <= maxValue) results.add(mid);
    start = end;
  }
  return results;
}

// Usage
FlutterRulerSlider(
  minValue: 20,
  maxValue: 100,
  interval: 10,
  width: 300,
  initialValue: 36,
  matchValues: _computeMidpoints(minValue: 20, maxValue: 100, interval: 10),
  tickStyle: const RulerTickStyle(matchColor: Colors.transparent),
)
```

For a complete, runnable example including displaying the selected value below the ruler, open the `example/` project.
