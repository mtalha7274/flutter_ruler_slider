## 0.0.7

- Fixed haptic feedback to trigger precisely on tick boundaries regardless of tick spacing

## 0.0.6
- Added haptic feedback support when scrolling through ticks
- New `enableHapticFeedback` parameter to enable/disable haptic feedback
- New `HapticSettings` class to configure feedback type and behavior
- Support for multiple haptic feedback types (light, medium, heavy, selection, vibrate)
- Option to trigger feedback on every tick or only on major ticks

## 0.0.5
- Added `labelAlignment` parameter to control label positioning (top or bottom relative to major ticks)
- Renamed `centerIndicator` to `indicator` for clarity
- Indicator now aligns based on `ticksAlignment` setting
- Labels now position relative to major tick marks instead of widget edges
- Fixed label clipping issues by adding proper overflow handling

## 0.0.4
- Added ticks alignment
- Changed naming conventions 

## 0.0.3
- Custom labels support added

## 0.0.2
- Added matched ticks: `matchValues` to mark specific ticks

## 0.0.1
- Initial release: flutter_ruler_slider created


