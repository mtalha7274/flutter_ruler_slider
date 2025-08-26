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
FlutterRuler(
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

For a complete, runnable example including displaying the selected value below the ruler, open the `example/` project.
