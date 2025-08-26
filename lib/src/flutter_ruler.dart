import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class RulerTickStyle {
  final double majorHeight;
  final double minorHeight;
  final double majorThickness;
  final double minorThickness;
  final Color majorColor;
  final Color minorColor;

  const RulerTickStyle({
    this.majorHeight = 30.0,
    this.minorHeight = 15.0,
    this.majorThickness = 1.2,
    this.minorThickness = 1.2,
    this.majorColor = Colors.black,
    this.minorColor = Colors.black,
  });
}

class FlutterRuler extends StatefulWidget {
  final int minValue, maxValue;
  final int interval;
  final int smallerInterval;
  final double tickSpacing;
  final double width, height;
  final int initialValue;
  final ValueChanged<double>? onValueChanged;
  final Widget? centerIndicator;
  final bool snapping;
  final Duration snappingDuration;
  final Curve snappingCurve;
  final bool showLabels;
  final bool showSubLabels;
  final double labelSpacing;
  final double labelRotation;
  final TextStyle? labelStyle;
  final RulerTickStyle tickStyle;

  const FlutterRuler({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.width,
    required this.initialValue,
    this.interval = 10,
    this.smallerInterval = 10,
    this.tickSpacing = 20,
    this.height = 100,
    this.onValueChanged,
    this.centerIndicator,
    this.snapping = false,
    this.snappingDuration = const Duration(milliseconds: 200),
    this.snappingCurve = Curves.linear,
    this.showLabels = true,
    this.showSubLabels = false,
    this.labelSpacing = 4,
    this.labelRotation = 0,
    this.labelStyle,
    this.tickStyle = const RulerTickStyle(),
  }) : assert(minValue < maxValue),
       assert(initialValue >= minValue && initialValue <= maxValue),
       assert(smallerInterval > 0);

  @override
  State<FlutterRuler> createState() => _RulerSliderState();
}

class _RulerSliderState extends State<FlutterRuler> {
  late final ScrollController _scroll;
  double? _lastValue;
  Timer? _snapTimer;

  int get _tickCount => widget.maxValue - widget.minValue + 1;
  double get _pxPerSubStep => widget.tickSpacing / widget.smallerInterval;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController()..addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToInitial());
  }

  void _jumpToInitial() {
    final offset = (widget.initialValue - widget.minValue) * widget.tickSpacing;
    _scroll.jumpTo(offset);
    _handleScroll();
  }

  void _handleScroll() {
    final centerOffset = _scroll.offset + widget.width / 2;
    final relativeOffset = centerOffset - widget.width / 2;
    final subSteps = (relativeOffset / _pxPerSubStep).round();
    final value = widget.minValue + subSteps / widget.smallerInterval;

    if (_lastValue == null || (_lastValue! - value).abs() > 1e-6) {
      _lastValue = value.clamp(
        widget.minValue.toDouble(),
        widget.maxValue.toDouble(),
      );
      widget.onValueChanged?.call(_lastValue!);
    }
  }

  void _startSnapDelay() {
    _snapTimer?.cancel();
    _snapTimer = Timer(const Duration(milliseconds: 100), _snapToNearestTick);
  }

  void _snapToNearestTick() {
    final centerOffset = _scroll.offset + widget.width / 2;
    final relativeOffset = centerOffset - widget.width / 2;
    final rawTickIndex = (relativeOffset / widget.tickSpacing).round();
    final targetOffset = rawTickIndex * widget.tickSpacing;
    final clampedOffset = targetOffset.clamp(
      0.0,
      _scroll.position.maxScrollExtent,
    );

    _scroll
        .animateTo(
          clampedOffset,
          duration: widget.snappingDuration,
          curve: widget.snappingCurve,
        )
        .then((_) {
          final snappedValue = widget.minValue + rawTickIndex;
          if (_lastValue != snappedValue.toDouble()) {
            _lastValue = snappedValue.toDouble();
            widget.onValueChanged?.call(_lastValue!);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final halfWidthPad = SizedBox(width: widget.width / 2);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!widget.snapping) return false;

        if (notification is ScrollUpdateNotification) {
          // Cancel any pending snap while the user (or animation) is still scrolling
          _snapTimer?.cancel();
        } else if (notification is ScrollEndNotification) {
          _startSnapDelay();
        }
        return false;
      },
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ListView.builder(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              itemCount: _tickCount + 2,
              itemBuilder: (ctx, i) {
                if (i == 0 || i == _tickCount + 1) return halfWidthPad;

                final tickIndex = i - 1;
                final tickValue = widget.minValue + tickIndex;
                // Major ticks every `interval` starting at minValue
                final isMajor = (tickIndex % widget.interval) == 0;
                final isFirst = tickIndex == 0;
                final isLast = tickIndex == _tickCount - 1;

                final tickWidget = CustomPaint(
                  painter: _TickPainter(
                    isMajor: isMajor,
                    label: tickValue.toString(),
                    showLabel:
                        widget.showLabels && (isMajor || widget.showSubLabels),
                    labelSpacing: widget.labelSpacing,
                    labelRotation: widget.labelRotation * math.pi / 180.0,
                    labelTextStyle:
                        widget.labelStyle ??
                        const TextStyle(fontSize: 12, color: Colors.black),
                    style: widget.tickStyle,
                  ),
                  child: SizedBox(
                    width: isFirst || isLast ? 0 : widget.tickSpacing,
                  ),
                );

                if (isFirst) {
                  return Row(
                    children: [
                      tickWidget,
                      SizedBox(width: widget.tickSpacing / 2),
                    ],
                  );
                } else if (isLast) {
                  return Row(
                    children: [
                      SizedBox(width: widget.tickSpacing / 2),
                      tickWidget,
                    ],
                  );
                } else {
                  return tickWidget;
                }
              },
            ),
            Positioned(
              top: 0,
              child:
                  widget.centerIndicator ??
                  Container(width: 2, height: widget.height, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    _snapTimer?.cancel();
    super.dispose();
  }
}

class _TickPainter extends CustomPainter {
  final bool isMajor;
  final bool showLabel;
  final String label;
  final double labelSpacing;
  final double labelRotation;
  final TextStyle labelTextStyle;
  final RulerTickStyle style;

  _TickPainter({
    required this.isMajor,
    required this.showLabel,
    required this.label,
    required this.labelSpacing,
    required this.labelRotation,
    required this.labelTextStyle,
    required this.style,
  });

  @override
  void paint(Canvas c, Size s) {
    final double length = isMajor ? style.majorHeight : style.minorHeight;
    final double strokeWidth = isMajor
        ? style.majorThickness
        : style.minorThickness;
    final Color color = isMajor ? style.majorColor : style.minorColor;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    final centerY = s.height / 2;

    c.drawLine(
      Offset(s.width / 2, centerY - length / 2),
      Offset(s.width / 2, centerY + length / 2),
      paint,
    );

    if (showLabel) {
      final tp = TextPainter(
        text: TextSpan(text: label, style: labelTextStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final dx = (s.width - tp.width) / 2;
      // Align labels using the major tick height baseline
      final dy = centerY + style.majorHeight / 2 + labelSpacing;

      if (labelRotation.abs() > 1e-6) {
        c.save();
        c.translate(dx + tp.width / 2, dy + tp.height / 2);
        c.rotate(labelRotation);
        c.translate(-tp.width / 2, -tp.height / 2);
        tp.paint(c, const Offset(0, 0));
        c.restore();
      } else {
        tp.paint(c, Offset(dx, dy));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TickPainter old) =>
      old.isMajor != isMajor ||
      old.label != label ||
      old.showLabel != showLabel ||
      old.labelSpacing != labelSpacing ||
      old.labelRotation != labelRotation ||
      old.labelTextStyle != labelTextStyle ||
      old.style != style;
}
