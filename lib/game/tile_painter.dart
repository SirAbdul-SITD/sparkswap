// lib/game/tile_painter.dart
import 'package:flutter/material.dart';
import 'tile.dart';
import '../utils/constants.dart';

/// Paints a SparkSwap tile straight from its connection mask.
/// Copper traces with rivet-style solder joints.
class TilePainter extends CustomPainter {
  final Tile tile;
  final bool selected;

  const TilePainter({required this.tile, this.selected = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final cx = w / 2, cy = h / 2;
    final pad = w * 0.05;

    // Tile background plate
    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(pad, pad, w - pad * 2, h - pad * 2),
        const Radius.circular(6));
    canvas.drawRRect(rrect, Paint()..color = kSurface);
    canvas.drawRRect(
        rrect,
        Paint()
          ..color = selected
              ? kSelect
              : tile.isPowered
                  ? kTraceOn.withOpacity(0.8)
                  : kBorder
          ..style = PaintingStyle.stroke
          ..strokeWidth = selected ? 2.5 : 1.2);

    if (tile.type == TileType.empty) {
      // Four tiny rivet dots so empty slots look like bare board
      final rp = Paint()..color = kBorder.withOpacity(0.5);
      for (final dx in [0.28, 0.72]) {
        for (final dy in [0.28, 0.72]) {
          canvas.drawCircle(Offset(w * dx, h * dy), w * 0.025, rp);
        }
      }
      return;
    }

    final traceColor = tile.isPowered ? kTraceOn : kTraceOff;
    final tw = w * 0.17;

    // Glow when powered
    if (tile.isPowered) {
      final gp = Paint()
        ..color = kTraceOn.withOpacity(0.4)
        ..strokeWidth = tw * 2.6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      _strokes(canvas, size, cx, cy, gp);
    }

    final tp = Paint()
      ..color = traceColor
      ..strokeWidth = tw
      ..strokeCap = StrokeCap.round;
    _strokes(canvas, size, cx, cy, tp);

    // Solder joint at centre
    if (tile.type == TileType.wire) {
      canvas.drawCircle(Offset(cx, cy), tw * 0.62, Paint()..color = traceColor);
      canvas.drawCircle(
          Offset(cx, cy),
          tw * 0.30,
          Paint()..color = kBg.withOpacity(0.5));
    }

    if (tile.type == TileType.source) _source(canvas, cx, cy, w);
    if (tile.type == TileType.bulb) _bulb(canvas, cx, cy, w);
  }

  void _strokes(Canvas canvas, Size s, double cx, double cy, Paint p) {
    final w = s.width, h = s.height;
    final e = w * 0.04;
    if (tile.hasTop) canvas.drawLine(Offset(cx, e), Offset(cx, cy), p);
    if (tile.hasRight) canvas.drawLine(Offset(cx, cy), Offset(w - e, cy), p);
    if (tile.hasBottom) canvas.drawLine(Offset(cx, cy), Offset(cx, h - e), p);
    if (tile.hasLeft) canvas.drawLine(Offset(e, cy), Offset(cx, cy), p);
  }

  void _source(Canvas canvas, double cx, double cy, double w) {
    final r = w * 0.22;
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = kSourceColor.withOpacity(0.16));
    canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = kSourceColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6);
    // plus / minus battery marks
    final mp = Paint()
      ..color = kSourceColor
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - r * 0.4, cy), Offset(cx + r * 0.4, cy), mp);
    canvas.drawLine(
        Offset(cx, cy - r * 0.4), Offset(cx, cy + r * 0.4), mp);
  }

  void _bulb(Canvas canvas, double cx, double cy, double w) {
    final r = w * 0.20;
    final color = tile.isPowered ? kBulbOn : kBulbOff;
    if (tile.isPowered) {
      canvas.drawCircle(
          Offset(cx, cy),
          r * 2.3,
          Paint()
            ..color = kBulbOn.withOpacity(0.45)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, r));
    }
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = color);
    // filament cross
    final fp = Paint()
      ..color = (tile.isPowered ? Colors.white : kBg).withOpacity(0.6)
      ..strokeWidth = 1.4;
    canvas.drawLine(Offset(cx - r * 0.5, cy + r * 0.2),
        Offset(cx + r * 0.5, cy + r * 0.2), fp);
    canvas.drawLine(Offset(cx - r * 0.3, cy - r * 0.25),
        Offset(cx + r * 0.3, cy - r * 0.25), fp);
  }

  @override
  bool shouldRepaint(TilePainter old) =>
      old.tile != tile ||
      old.tile.isPowered != tile.isPowered ||
      old.selected != selected;
}
