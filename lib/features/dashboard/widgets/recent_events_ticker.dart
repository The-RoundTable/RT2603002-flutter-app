import 'package:flutter/material.dart';
import '../providers/session_provider.dart';

/// Scrollable list of recent AI detection events.
/// New events slide in from the top.
class RecentEventsTicker extends StatefulWidget {
  final List<DmsEvent> events;

  const RecentEventsTicker({super.key, required this.events});

  @override
  State<RecentEventsTicker> createState() => _RecentEventsTickerState();
}

class _RecentEventsTickerState extends State<RecentEventsTicker> {
  final _scrollController = ScrollController();
  List<DmsEvent> _prev = [];

  @override
  void didUpdateWidget(RecentEventsTicker old) {
    super.didUpdateWidget(old);
    if (widget.events.length != _prev.length) {
      _prev = widget.events;
      // Auto-scroll to top when new event arrives
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📋', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text(
                'No events yet',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ListView.separated(
          controller: _scrollController,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: widget.events.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: Colors.white.withValues(alpha: 0.05),
            indent: 16,
            endIndent: 16,
          ),
          itemBuilder: (context, index) {
            final event = widget.events[index];
            final color = _severityColor(event.severity);
            final isNew = index == 0;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: isNew
                  ? color.withValues(alpha: 0.06)
                  : Colors.transparent,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  // Severity dot
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Event type icon + name
                  Text(
                    event.eventType.icon,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      event.eventType.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Confidence
                  Text(
                    '${(event.confidenceScore * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Severity badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: color.withValues(alpha: 0.3), width: 0.5),
                    ),
                    child: Text(
                      event.severity.label,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Time ago
                  Text(
                    _timeAgo(event.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}