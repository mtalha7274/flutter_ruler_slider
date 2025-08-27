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
  tickSpacing: 20,
  ticksAlignment: TicksAlignment.center,
  tickStyle: const TicksStyle(
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

### Matched ticks
Highlight specific ticks by value using `matchValues`. Matched ticks use `TicksStyle.matchHeight`, `matchThickness`, and `matchColor` (defaults: 15.0, 1.2, transparent).

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
  tickStyle: const TicksStyle(matchColor: Colors.transparent),
)
```

For a complete, runnable example including displaying the selected value below the ruler, open the `example/` project.

### Custom labels
Provide your own labels using `customLabels`. The list is normalized to match the number of labels that would be generated (major-only when `showSubLabels: false`, or every tick when `showSubLabels: true`):

- Equal length: used as-is.
- Fewer: the tail slice from generated labels is appended to match length.
- More: extra values are trimmed from the end.

Example (shorter list gets extended from the end of generated labels):

```dart
FlutterRulerSlider(
  minValue: 0,
  maxValue: 100,
  initialValue: 50,
  width: 300,
  interval: 10,
  showLabels: true,
  showSubLabels: false, // set true to label every tick (including minors)
  customLabels: const ['10','20','30','50'],
)
```

If generated labels are `[0, 10, 20, ..., 90, 100]`, the above becomes `['10','20','30','50', '60','70','80','90','100']`.

Notes:
- When `showSubLabels` is true, labels apply to every tick (major and minor). You can still pass fewer labels; they will be extended using the same rule.
- Labels are rendered as strings; convert values to strings before passing if needed.
