import 'package:flutter/material.dart';
import '../providers/session_provider.dart';

/// Grid of 4 cards — one per event type.
/// Shows last severity, confidence %, and event count.
class StatusCardsGrid extends StatelessWidget {
  final Map<EventType, EventCardState> cardStates;
  final bool isActive;

  const StatusCardsGrid({
    super.key,
    required this.cardStates,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: EventType.values.map((type) {
        final state = cardStates[type];
        return _StatusCard(
          type: type,
          cardState: state,
          isActive: isActive,
        );
      }).toList(),
    );
  }
}

class _StatusCard extends StatefulWidget {
  final EventType type;
  final EventCardState? cardState;
  final bool isActive;

  const _StatusCard({
    required this.type,
    required this.cardState,
    required this.isActive,
  });

  @override
  State<_StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends State<_StatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  Severity? _prevSeverity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(_StatusCard old) {
    super.didUpdateWidget(old);
    final newSev = widget.cardState?.lastSeverity;
    if (newSev != null && newSev != _prevSeverity) {
      _prevSeverity = newSev;
      _pulse
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  static Color _severityColor(Severity? s) {
    switch (s) {
      case Severity.low:
        return const Color(0xFF00E676);
      case Severity.medium:
        return const Color(0xFFFFD600);
      case Severity.high:
        return const Color(0xFFFF6D00);
      case Severity.critical:
        return const Color(0xFFFF1744);
      case null:
        return Colors.white24;
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.cardState;
    final severity = card?.lastSeverity;
    final color = _severityColor(severity);
    final hasData = widget.isActive && card != null && card.countInSession > 0;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final pulseOpacity = hasData
            ? (1.0 - _pulse.value * 0.4)
            : 1.0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(
            color: hasData
                ? color.withValues(alpha: 0.07)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasData
                  ? color.withValues(alpha: 0.25 * pulseOpacity)
                  : Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ── Header ──────────────────────────────────────
              Row(
                children: [
                  Text(
                    widget.type.icon,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.type.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasData)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '×${card!.countInSession}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                ],
              ),

              // ── Bottom info ──────────────────────────────────
              if (!widget.isActive)
                Text(
                  'Session inactive',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                )
              else if (!hasData)
                Text(
                  'No detections yet',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                )
              else ...[
                Text(
                  severity!.label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -0.5,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${((card!.lastConfidence ?? 0) * 100).toStringAsFixed(0)}% conf.',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    const Spacer(),
                    // Mini confidence bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: SizedBox(
                        width: 40,
                        height: 4,
                        child: LinearProgressIndicator(
                          value: card.lastConfidence ?? 0,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation(
                            color.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}