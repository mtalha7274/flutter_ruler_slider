import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Styling options for ruler ticks (major, minor, and matched).
///
/// Use this to control the visual appearance of tick marks:
/// - Heights define how tall each tick line is.
/// - Thickness controls the stroke width.
/// - Colors set the paint color per tick type.
///
/// Matched ticks are those whose values are included in
/// [FlutterRulerSlider.matchValues]. Matched properties have explicit defaults
/// (height 15.0, thickness 1.2, color transparent).
class TicksStyle {
  /// Height of each major tick line in logical pixels.
  final double majorHeight;

  /// Height of each minor (sub) tick line in logical pixels.
  final double minorHeight;

  /// Height of a matched tick line in logical pixels.
  ///
  /// Defaults to 15.0. A tick is considered
  /// "matched" when its value is included in [FlutterRulerSlider.matchValues].
  final double matchHeight;

  /// Stroke width of major tick lines.
  final double majorThickness;

  /// Stroke width of minor tick lines.
  final double minorThickness;

  /// Stroke width of matched tick lines.
  ///
  /// Defaults to 1.2.
  final double matchThickness;

  /// Color used to paint major tick lines.
  final Color majorColor;

  /// Color used to paint minor tick lines.
  final Color minorColor;

  /// Color used to paint matched tick lines.
  ///
  /// Defaults to [Colors.transparent].
  final Color matchColor;

  /// Creates a tick style with sensible defaults.
  const TicksStyle({
    this.majorHeight = 30.0,
    this.minorHeight = 15.0,
    this.matchHeight = 15.0,
    this.majorThickness = 1.2,
    this.minorThickness = 1.2,
    this.matchThickness = 1.2,
    this.majorColor = Colors.black,
    this.minorColor = Colors.black,
    this.matchColor = Colors.transparent,
  });
}

/// Vertical alignment for ruler tick marks.
///
/// - [center]: Ticks are centered vertically (existing behavior).
/// - [top]: Ticks start at the top and extend downward.
/// - [bottom]: Ticks start at the bottom and extend upward.
enum TicksAlignment { center, top, bottom }

/// Vertical alignment for labels relative to major tick marks.
///
/// - [top]: Labels are positioned above the top edge of major ticks.
/// - [bottom]: Labels are positioned below the bottom edge of major ticks.
enum LabelAlignment { top, bottom }

/// A horizontally scrollable, snap-capable ruler slider with tick marks and labels.
///
/// - Drag freely to update the value continuously.
/// - When [snapping] is true, the scroll position animates to the nearest whole
///   tick after the scroll ends.
/// - Major tick labels can be shown, and optionally on minor ticks via
///   [showSubLabels]. All labels are aligned along a common baseline defined by
///   the major tick height and [labelSpacing].
/// - You can highlight specific ticks as "matched" via [matchValues]. Matched
///   ticks use [TicksStyle.matchHeight], [TicksStyle.matchThickness],
///   and [TicksStyle.matchColor]. These have explicit defaults
///   (15.0, 1.2, transparent).
class FlutterRulerSlider extends StatefulWidget {
  /// Inclusive minimum value represented by the first tick.
  final int minValue, maxValue;

  /// Interval (in value units) between major ticks and labels.
  ///
  /// For example, with `minValue = 0`, `interval = 10`, you get labels at
  /// 0, 10, 20, ...
  final int interval;

  /// Number of sub-steps within 1 whole value unit.
  ///
  /// Determines the granularity of the reported [onValueChanged] value while
  /// scrolling between two integer ticks. For example, `smallerInterval = 10`
  /// allows values like 35.1, 35.2, ...
  final int smallerInterval;

  /// Spacing in logical pixels between adjacent integer ticks.
  final double tickSpacing;

  /// Fixed size of the widget.
  final double width, height;

  /// Initial selected integer value. Must be within [minValue] and [maxValue].
  final int initialValue;

  /// Called whenever the current value changes due to scrolling or snapping.
  ///
  /// The value can be fractional depending on [smallerInterval].
  final ValueChanged<double>? onValueChanged;

  /// Widget rendered as the central indicator (defaults to a red vertical line).
  final Widget? indicator;

  /// When true, snap to the nearest tick after scrolling ends.
  final bool snapping;

  /// Duration of the snapping animation when [snapping] is true.
  final Duration snappingDuration;

  /// Curve of the snapping animation when [snapping] is true.
  final Curve snappingCurve;

  /// Whether to show labels under ticks.
  final bool showLabels;

  /// When [showLabels] is true, also show labels under minor ticks.
  final bool showSubLabels;

  /// Vertical spacing between the major tick and the labels.
  final double labelSpacing;

  /// Label rotation in degrees (clockwise), applied around label center.
  final double labelRotation;

  /// Text style applied to labels (defaults to 12sp black when null).
  final TextStyle? labelStyle;

  /// Vertical alignment for labels (top or bottom).
  ///
  /// Defaults to [LabelAlignment.bottom]. When set to bottom, labels are
  /// positioned below the major tick's bottom edge. When set to top, labels
  /// are positioned above the major tick's top edge. Distance is controlled
  /// by [labelSpacing].
  final LabelAlignment labelAlignment;

  /// Visual style for tick marks (heights, thicknesses, colors).
  final TicksStyle tickStyle;

  /// Vertical alignment of ruler ticks.
  ///
  /// Defaults to [TicksAlignment.center]. When set to [TicksAlignment.top],
  /// ticks (major, minor, and matched) originate from the top. When set to
  /// [TicksAlignment.bottom], ticks originate from the bottom.
  final TicksAlignment ticksAlignment;

  /// List of integer values whose ticks should be rendered as "matched".
  ///
  /// A tick is considered matched when its integer value exists in this list.
  /// Matched ticks use the styling provided by [TicksStyle.matchHeight],
  /// [TicksStyle.matchThickness], and [TicksStyle.matchColor].
  final List<int>? matchValues;

  /// Optional custom labels to display under ticks.
  ///
  /// When provided, they are normalized to match the number of labels that
  /// would normally be generated (major-only or including sublabels depending
  /// on [showSubLabels]) using the rules:
  /// - If equal length, use as-is.
  /// - If fewer, append the tail slice from generated labels to match length.
  /// - If more, trim extras from the end.
  final List<String>? customLabels;

  /// Creates a [FlutterRulerSlider].
  const FlutterRulerSlider({
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
    this.indicator,
    this.snapping = false,
    this.snappingDuration = const Duration(milliseconds: 200),
    this.snappingCurve = Curves.linear,
    this.showLabels = true,
    this.showSubLabels = false,
    this.labelSpacing = 4,
    this.labelRotation = 0,
    this.labelStyle,
    this.labelAlignment = LabelAlignment.bottom,
    this.tickStyle = const TicksStyle(),
    this.ticksAlignment = TicksAlignment.center,
    this.matchValues,
    this.customLabels,
  }) : assert(minValue < maxValue),
       assert(initialValue >= minValue && initialValue <= maxValue),
       assert(smallerInterval > 0);

  @override
  State<FlutterRulerSlider> createState() => _RulerSliderState();
}

class _RulerSliderState extends State<FlutterRulerSlider> {
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

    // Precompute the labels that should be shown and map them to tick indices.
    final _LabelMapping labelMapping = _computeLabelMapping();

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
      child: ClipRect(
        clipBehavior: Clip.none,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              ListView.builder(
                controller: _scroll,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                clipBehavior: Clip.none,
                itemCount: _tickCount + 2,
                itemBuilder: (ctx, i) {
                  if (i == 0 || i == _tickCount + 1) return halfWidthPad;

                  final tickIndex = i - 1;
                  final tickValue = widget.minValue + tickIndex;
                  // Major ticks every `interval` starting at minValue
                  final isMajor = (tickIndex % widget.interval) == 0;
                  final isMatched =
                      widget.matchValues?.contains(tickValue) ?? false;
                  final isFirst = tickIndex == 0;
                  final isLast = tickIndex == _tickCount - 1;

                  final String effectiveLabel =
                      labelMapping.labelsByTickIndex[tickIndex] ??
                      tickValue.toString();

                  final tickWidget = CustomPaint(
                    painter: _TickPainter(
                      isMajor: isMajor,
                      isMatched: isMatched,
                      label: effectiveLabel,
                      showLabel:
                          widget.showLabels &&
                          (isMajor || widget.showSubLabels),
                      labelSpacing: widget.labelSpacing,
                      labelRotation: widget.labelRotation * math.pi / 180.0,
                      labelTextStyle:
                          widget.labelStyle ??
                          const TextStyle(fontSize: 12, color: Colors.black),
                      labelAlignment: widget.labelAlignment,
                      style: widget.tickStyle,
                      alignment: widget.ticksAlignment,
                    ),
                    size: Size(
                      isFirst || isLast ? 0 : widget.tickSpacing,
                      widget.height,
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
              _buildIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    final defaultIndicator = Container(
      width: 2,
      height: widget.height,
      color: Colors.red,
    );
    final indicator = widget.indicator ?? defaultIndicator;

    switch (widget.ticksAlignment) {
      case TicksAlignment.top:
        return Positioned(top: 0, child: indicator);
      case TicksAlignment.bottom:
        return Positioned(bottom: 0, child: indicator);
      case TicksAlignment.center:
        return Positioned(top: 0, child: indicator);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _snapTimer?.cancel();
    super.dispose();
  }
}

class _LabelMapping {
  final Map<int, String> labelsByTickIndex;
  const _LabelMapping(this.labelsByTickIndex);
}

extension on _RulerSliderState {
  _LabelMapping _computeLabelMapping() {
    if (!widget.showLabels) {
      return const _LabelMapping(<int, String>{});
    }

    // Determine which tick indices will show labels
    final List<int> labelTickIndices = <int>[];
    for (int i = 0; i < _tickCount; i++) {
      final bool isMajor = (i % widget.interval) == 0;
      if (isMajor || widget.showSubLabels) {
        labelTickIndices.add(i);
      }
    }

    if (labelTickIndices.isEmpty) {
      return const _LabelMapping(<int, String>{});
    }

    // Generated labels as strings
    final List<String> generatedLabels = labelTickIndices
        .map((i) => (widget.minValue + i).toString())
        .toList(growable: false);

    final List<String>? custom = widget.customLabels;
    if (custom == null || custom.isEmpty) {
      // No custom labels provided; default behavior uses generated labels in painter
      return const _LabelMapping(<int, String>{});
    }

    // Normalize custom labels to match generated labels length
    final int desiredLength = generatedLabels.length;
    List<String> normalized = List<String>.from(custom);

    if (normalized.length > desiredLength) {
      normalized = normalized.sublist(0, desiredLength);
    } else if (normalized.length < desiredLength) {
      final List<String> toAppendReversed = <String>[];
      int gi = generatedLabels.length - 1;
      while (normalized.length + toAppendReversed.length < desiredLength &&
          gi >= 0) {
        final String candidate = generatedLabels[gi];
        if (normalized.isEmpty || candidate != normalized.last) {
          toAppendReversed.add(candidate);
        }
        gi--;
      }
      // Append in correct order
      toAppendReversed.reversed.forEach(normalized.add);
      // If still short (shouldn't happen), pad from start of generated
      int si = 0;
      while (normalized.length < desiredLength && si < generatedLabels.length) {
        if (normalized.isEmpty || generatedLabels[si] != normalized.last) {
          normalized.add(generatedLabels[si]);
        } else {
          normalized.add(generatedLabels[si]);
        }
        si++;
      }
    }

    // Build mapping from tick indices to labels in order
    final Map<int, String> map = <int, String>{};
    for (int k = 0; k < labelTickIndices.length; k++) {
      map[labelTickIndices[k]] = normalized[k];
    }
    return _LabelMapping(map);
  }
}

class _TickPainter extends CustomPainter {
  final bool isMajor;
  final bool isMatched;
  final bool showLabel;
  final String label;
  final double labelSpacing;
  final double labelRotation;
  final TextStyle labelTextStyle;
  final LabelAlignment labelAlignment;
  final TicksStyle style;
  final TicksAlignment alignment;

  _TickPainter({
    required this.isMajor,
    required this.isMatched,
    required this.showLabel,
    required this.label,
    required this.labelSpacing,
    required this.labelRotation,
    required this.labelTextStyle,
    required this.labelAlignment,
    required this.style,
    required this.alignment,
  });

  @override
  void paint(Canvas c, Size s) {
    final bool useMatched = isMatched;
    final double length = useMatched
        ? style.matchHeight
        : (isMajor ? style.majorHeight : style.minorHeight);
    final double strokeWidth = useMatched
        ? style.matchThickness
        : (isMajor ? style.majorThickness : style.minorThickness);
    final Color color = useMatched
        ? style.matchColor
        : (isMajor ? style.majorColor : style.minorColor);

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    final centerY = s.height / 2;
    double startY;
    double endY;
    switch (alignment) {
      case TicksAlignment.center:
        startY = centerY - length / 2;
        endY = centerY + length / 2;
        break;
      case TicksAlignment.top:
        startY = 0;
        endY = length;
        break;
      case TicksAlignment.bottom:
        startY = s.height - length;
        endY = s.height;
        break;
    }

    c.drawLine(Offset(s.width / 2, startY), Offset(s.width / 2, endY), paint);

    if (showLabel) {
      final tp = TextPainter(
        text: TextSpan(text: label, style: labelTextStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final dx = (s.width - tp.width) / 2;

      // First, determine where the major tick ends based on tick alignment
      double majorTickTopEnd;
      double majorTickBottomEnd;

      switch (alignment) {
        case TicksAlignment.center:
          majorTickTopEnd = centerY - style.majorHeight / 2;
          majorTickBottomEnd = centerY + style.majorHeight / 2;
          break;
        case TicksAlignment.top:
          majorTickTopEnd = 0;
          majorTickBottomEnd = style.majorHeight;
          break;
        case TicksAlignment.bottom:
          majorTickTopEnd = s.height - style.majorHeight;
          majorTickBottomEnd = s.height;
          break;
      }

      // Then position label relative to the major tick using labelAlignment
      final double dy;
      switch (labelAlignment) {
        case LabelAlignment.bottom:
          // Place labels below the bottom end of the major tick
          dy = majorTickBottomEnd + labelSpacing;
          break;
        case LabelAlignment.top:
          // Place labels above the top end of the major tick
          dy = majorTickTopEnd - labelSpacing - tp.height;
          break;
      }

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
      old.isMatched != isMatched ||
      old.label != label ||
      old.showLabel != showLabel ||
      old.labelSpacing != labelSpacing ||
      old.labelRotation != labelRotation ||
      old.labelTextStyle != labelTextStyle ||
      old.labelAlignment != labelAlignment ||
      old.style != style ||
      old.alignment != alignment;
}
