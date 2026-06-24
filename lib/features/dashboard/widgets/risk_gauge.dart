import 'dart:math';
import 'package:flutter/material.dart';
import '../providers/session_provider.dart';

/// Animated arc gauge that shows overall driver risk level.
/// Color and needle animate smoothly on severity change.
class RiskGauge extends StatefulWidget {
  final double riskScore; // 0.0 – 1.0
  final Severity severity;
  final bool isActive;

  const RiskGauge({
    super.key,
    required this.riskScore,
    required this.severity,
    required this.isActive,
  });

  @override
  State<RiskGauge> createState() => _RiskGaugeState();
}

class _RiskGaugeState extends State<RiskGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnim;
  late Animation<Color?> _colorAnim;

  double _prevScore = 0.0;
  Color _prevColor = _severityColor(Severity.low);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _buildAnimations(widget.riskScore, widget.severity);
  }

  @override
  void didUpdateWidget(RiskGauge old) {
    super.didUpdateWidget(old);
    if (old.riskScore != widget.riskScore ||
        old.severity != widget.severity) {
      _prevScore = old.riskScore;
      _prevColor = _severityColor(old.severity);
      _buildAnimations(widget.riskScore, widget.severity);
      _controller
        ..reset()
        ..forward();
    }
  }

  void _buildAnimations(double targetScore, Severity targetSev) {
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _scoreAnim = Tween<double>(
      begin: _prevScore,
      end: targetScore,
    ).animate(curve);

    _colorAnim = ColorTween(
      begin: _prevColor,
      end: _severityColor(targetSev),
    ).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static Color _severityColor(Severity s) {
    switch (s) {
      case Severity.low:
        return const Color(0xFF00E676);
      case Severity.medium:
        return const Color(0xFFFFD600);
      case Severity.high:
        return const Color(0xFFFF6D00);
      case Severity.critical:
        return const Color(0xFFFF1744);
    }
  }

  String _severityLabel(Severity s) {
    switch (s) {
      case Severity.low:
        return 'LOW RISK';
      case Severity.medium:
        return 'MODERATE';
      case Severity.high:
        return 'HIGH RISK';
      case Severity.critical:
        return 'CRITICAL';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final score = _scoreAnim.value;
        final color = _colorAnim.value ?? _severityColor(widget.severity);

        return Column(
          children: [
            SizedBox(
              width: 220,
              height: 130,
              child: CustomPaint(
                painter: _GaugePainter(
                  score: score,
                  color: color,
                  isActive: widget.isActive,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.isActive
                              ? '${(score * 100).toInt()}%'
                              : '--',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: widget.isActive ? color : Colors.white24,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.isActive
                              ? _severityLabel(widget.severity)
                              : 'SESSION IDLE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: widget.isActive
                                ? color.withValues(alpha: 0.8)
                                : Colors.white24,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Severity tick labels
            SizedBox(
              width: 220,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _TickLabel('LOW'),
                  _TickLabel('MED'),
                  _TickLabel('HIGH'),
                  _TickLabel('CRIT'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TickLabel extends StatelessWidget {
  final String label;
  const _TickLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 9,
        color: Colors.white30,
        letterSpacing: 1,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double score;
  final Color color;
  final bool isActive;

  _GaugePainter({
    required this.score,
    required this.color,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height - 10;
    final radius = size.width / 2 - 10;

    // Arc goes from 180° to 0° (left to right, semicircle)
    const startAngle = pi; // 180°
    const sweepTotal = pi; // 180° total

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // ── Background track ──────────────────────────────────────
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweepTotal, false, trackPaint);

    // ── Filled arc (risk level) ───────────────────────────────
    if (isActive && score > 0) {
      final fillPaint = Paint()
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: startAngle,
          endAngle: startAngle + sweepTotal * score,
          colors: [
            color.withValues(alpha: 0.6),
            color,
          ],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweepTotal * score, false, fillPaint);

      // Glow effect on tip
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawArc(
        rect,
        startAngle + sweepTotal * score - 0.02,
        0.02,
        false,
        glowPaint,
      );
    }

    // ── Severity zone dots ────────────────────────────────────
    final dotPositions = [0.0, 0.33, 0.66, 1.0];
    final dotColors = [
      const Color(0xFF00E676),
      const Color(0xFFFFD600),
      const Color(0xFFFF6D00),
      const Color(0xFFFF1744),
    ];
    for (var i = 0; i < dotPositions.length; i++) {
      final angle = startAngle + sweepTotal * dotPositions[i];
      final dx = cx + (radius) * cos(angle);
      final dy = cy + (radius) * sin(angle);
      canvas.drawCircle(
        Offset(dx, dy),
        3,
        Paint()..color = dotColors[i].withValues(alpha: 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.score != score || old.color != color || old.isActive != isActive;
}