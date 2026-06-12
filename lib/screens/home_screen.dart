// lib/screens/home_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/preferences.dart';
import 'level_select_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completed = Preferences.instance.getCompletedCount();
    final totalStars = Preferences.instance.getTotalStars();

    return Scaffold(
      backgroundColor: kBg,
      body: Stack(children: [
        CustomPaint(
            size: MediaQuery.of(context).size, painter: _CopperBgPainter()),
        SafeArea(
          child: Column(children: [
            const Spacer(flex: 2),
            // Swap icon animation
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                final t = Curves.easeInOut.transform(_ctrl.value);
                return SizedBox(
                  width: 150,
                  height: 70,
                  child: Stack(children: [
                    Positioned(
                        left: 10 + t * 70,
                        top: 10,
                        child: _miniTile(kTraceOn)),
                    Positioned(
                        left: 80 - t * 70,
                        top: 10,
                        child: _miniTile(kSourceColor)),
                  ]),
                );
              },
            ),
            const SizedBox(height: 20),
            Text('SPARKSWAP',
                style: techno(40,
                    color: kAccent, weight: FontWeight.w900, letterSpacing: 7)),
            const SizedBox(height: 8),
            Text('SWAP  ·  SOLDER  ·  SHINE',
                style: techno(12, color: kTextDim, letterSpacing: 4)),
            const SizedBox(height: 28),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _chip(Icons.check_circle_outline, '$completed / $kTotalLevels',
                  kEasyColor),
              const SizedBox(width: 14),
              _chip(Icons.star, '$totalStars', kStarOn),
            ]),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 52),
              child: Column(children: [
                _btn('PLAY', Icons.play_arrow_rounded, true, () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const LevelSelectScreen()));
                }),
                const SizedBox(height: 14),
                _btn('SETTINGS', Icons.tune_rounded, false, () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const SettingsScreen()));
                }),
              ]),
            ),
            const SizedBox(height: 56),
          ]),
        ),
      ]),
    );
  }

  Widget _miniTile(Color color) => Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 2),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 14)],
        ),
        child: Icon(Icons.bolt, color: color, size: 26),
      );

  Widget _chip(IconData icon, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorder),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label, style: techno(13)),
        ]),
      );

  Widget _btn(String label, IconData icon, bool primary, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: primary
                ? const LinearGradient(
                    colors: [Color(0xFFB36A1B), Color(0xFFE08A2E)])
                : null,
            color: primary ? null : kSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: primary ? kAccent.withOpacity(0.7) : kBorder,
                width: primary ? 1.5 : 1),
            boxShadow: primary
                ? [BoxShadow(color: kAccent.withOpacity(0.3), blurRadius: 22)]
                : null,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: primary ? Colors.white : kTextDim, size: 20),
            const SizedBox(width: 10),
            Text(label,
                style: techno(15,
                    color: primary ? Colors.white : kTextDim,
                    letterSpacing: 3)),
          ]),
        ),
      );
}

class _CopperBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(7);
    final p = Paint()
      ..color = kBorder.withOpacity(0.35)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    // Random manhattan copper traces
    for (int i = 0; i < 16; i++) {
      double x = rng.nextDouble() * size.width;
      double y = rng.nextDouble() * size.height;
      final path = Path()..moveTo(x, y);
      for (int s = 0; s < 4; s++) {
        if (rng.nextBool()) {
          x += (rng.nextDouble() - 0.5) * 200;
        } else {
          y += (rng.nextDouble() - 0.5) * 200;
        }
        path.lineTo(x, y);
      }
      canvas.drawPath(path, p..style = PaintingStyle.stroke);
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = kBorder);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
