import 'package:flutter/material.dart';

class PillSliderTrackShape extends SliderTrackShape {
  const PillSliderTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = 8;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
  }) {
    final Canvas canvas = context.canvas;
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final double pillRadius = trackRect.height / 2;
    final RRect trackRRect = RRect.fromRectAndRadius(
      trackRect,
      Radius.circular(pillRadius),
    );
    // Draw inactive track
    canvas.drawRRect(
      trackRRect,
      Paint()..color = sliderTheme.inactiveTrackColor ?? Colors.grey,
    );
    // draw active track
    final double activeWidth = thumbCenter.dx - trackRect.left;
    final Rect activeRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      trackRect.left + activeWidth,
      trackRect.bottom,
    );
    final RRect activeRRect = RRect.fromRectAndRadius(
      activeRect,
      Radius.circular(pillRadius),
    );
    canvas.drawRRect(
      activeRRect,
      Paint()..color = sliderTheme.activeTrackColor ?? Colors.blue,
    );
  }
}

class PillSliderThumbShape extends SliderComponentShape {
  const PillSliderThumbShape({this.width = 16, this.height = 16});
  final double width;
  final double height;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(width, height);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final Color color = sliderTheme.thumbColor ?? Colors.blue;
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: width, height: height),
      Radius.circular(height / 2),
    );
    canvas.drawRRect(rrect, Paint()..color = color);
  }
}

class VerticalBarSliderOverlayShape extends SliderComponentShape {
  const VerticalBarSliderOverlayShape({this.width = 8, this.height = 40});
  final double width;
  final double height;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(width, height);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final Color color =
        sliderTheme.overlayColor?.withValues(alpha: 0.25) ??
        Colors.blue.withValues(alpha: 0.25);
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: width, height: height),
      Radius.circular(width / 2),
    );
    canvas.drawRRect(rrect, Paint()..color = color);
  }
}

class VerticalBarSliderThumbShape extends SliderComponentShape {
  const VerticalBarSliderThumbShape({this.width = 4, this.height = 32});
  final double width;
  final double height;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(width, height);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final Color color = sliderTheme.thumbColor ?? Colors.blue;
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: width, height: height),
      Radius.circular(width / 2),
    );
    canvas.drawRRect(rrect, Paint()..color = color);
  }
}
