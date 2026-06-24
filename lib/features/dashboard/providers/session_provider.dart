import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum Severity { low, medium, high, critical }

enum EventType { drowsiness, eyesClosed, yawning, headPose }

extension SeverityExt on Severity {
  String get label => name.toUpperCase();

  // Maps to a 0.0–1.0 risk score for the gauge
  double get riskScore {
    switch (this) {
      case Severity.low:
        return 0.15;
      case Severity.medium:
        return 0.45;
      case Severity.high:
        return 0.72;
      case Severity.critical:
        return 0.95;
    }
  }
}

extension EventTypeExt on EventType {
  String get label {
    switch (this) {
      case EventType.drowsiness:
        return 'Drowsiness';
      case EventType.eyesClosed:
        return 'Eyes Closed';
      case EventType.yawning:
        return 'Yawning';
      case EventType.headPose:
        return 'Head Pose';
    }
  }

  String get icon {
    switch (this) {
      case EventType.drowsiness:
        return '😴';
      case EventType.eyesClosed:
        return '👁️';
      case EventType.yawning:
        return '🥱';
      case EventType.headPose:
        return '🔄';
    }
  }
}

// ─── Models ───────────────────────────────────────────────────────────────────

class DmsEvent {
  final String id;
  final EventType eventType;
  final Severity severity;
  final double confidenceScore;
  final DateTime timestamp;
  final String? sessionId;

  const DmsEvent({
    required this.id,
    required this.eventType,
    required this.severity,
    required this.confidenceScore,
    required this.timestamp,
    this.sessionId,
  });

  /// Parse from real WebSocket JSON — plug in later
  factory DmsEvent.fromJson(Map<String, dynamic> json) {
    return DmsEvent(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      eventType: _parseEventType(json['event_type'] as String),
      severity: _parseSeverity(json['severity'] as String),
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      sessionId: json['session_id'] as String?,
    );
  }

  static EventType _parseEventType(String raw) {
    switch (raw.toLowerCase()) {
      case 'drowsiness':
        return EventType.drowsiness;
      case 'eyes_closed':
        return EventType.eyesClosed;
      case 'yawning':
        return EventType.yawning;
      case 'head_pose':
        return EventType.headPose;
      default:
        return EventType.drowsiness;
    }
  }

  static Severity _parseSeverity(String raw) {
    switch (raw.toUpperCase()) {
      case 'LOW':
        return Severity.low;
      case 'MEDIUM':
        return Severity.medium;
      case 'HIGH':
        return Severity.high;
      case 'CRITICAL':
        return Severity.critical;
      default:
        return Severity.low;
    }
  }
}

/// Per-event-type running state shown in status cards
class EventCardState {
  final EventType type;
  final Severity? lastSeverity;
  final double? lastConfidence;
  final DateTime? lastSeen;
  final int countInSession;

  const EventCardState({
    required this.type,
    this.lastSeverity,
    this.lastConfidence,
    this.lastSeen,
    this.countInSession = 0,
  });

  EventCardState copyWith({
    Severity? lastSeverity,
    double? lastConfidence,
    DateTime? lastSeen,
    int? countInSession,
  }) {
    return EventCardState(
      type: type,
      lastSeverity: lastSeverity ?? this.lastSeverity,
      lastConfidence: lastConfidence ?? this.lastConfidence,
      lastSeen: lastSeen ?? this.lastSeen,
      countInSession: countInSession ?? this.countInSession,
    );
  }
}

// ─── Session State ─────────────────────────────────────────────────────────────

class SessionState {
  final bool isActive;
  final String? sessionId;
  final DateTime? startTime;
  final List<DmsEvent> recentEvents; // last 20
  final Map<EventType, EventCardState> cardStates;
  final Severity currentSeverity;
  final double riskScore; // 0.0 – 1.0

  const SessionState({
    this.isActive = false,
    this.sessionId,
    this.startTime,
    this.recentEvents = const [],
    this.cardStates = const {},
    this.currentSeverity = Severity.low,
    this.riskScore = 0.0,
  });

  SessionState copyWith({
    bool? isActive,
    String? sessionId,
    DateTime? startTime,
    List<DmsEvent>? recentEvents,
    Map<EventType, EventCardState>? cardStates,
    Severity? currentSeverity,
    double? riskScore,
  }) {
    return SessionState(
      isActive: isActive ?? this.isActive,
      sessionId: sessionId ?? this.sessionId,
      startTime: startTime ?? this.startTime,
      recentEvents: recentEvents ?? this.recentEvents,
      cardStates: cardStates ?? this.cardStates,
      currentSeverity: currentSeverity ?? this.currentSeverity,
      riskScore: riskScore ?? this.riskScore,
    );
  }
}

// ─── Session Notifier ──────────────────────────────────────────────────────────

class SessionNotifier extends AsyncNotifier<SessionState> {
  Timer? _mockTimer;
  final _rng = Random();

  // ── Mock event stream (replace with real WebSocket later) ──
  static const _mockEventTypes = EventType.values;
  static const _mockSeverities = Severity.values;

  @override
  Future<SessionState> build() async {
    // Initialise with empty idle state
    ref.onDispose(() {
      _mockTimer?.cancel();
    });
    return const SessionState();
  }

  // ── Public API ─────────────────────────────────────────────

  Future<void> startSession() async {
    final prev = state.value ?? const SessionState();
    final sessionId = 'mock-session-${DateTime.now().millisecondsSinceEpoch}';

    // Initialise card states for all event types
    final cards = {
      for (final t in EventType.values) t: EventCardState(type: t),
    };

    state = AsyncData(
      prev.copyWith(
        isActive: true,
        sessionId: sessionId,
        startTime: DateTime.now(),
        recentEvents: [],
        cardStates: cards,
        currentSeverity: Severity.low,
        riskScore: 0.0,
      ),
    );

    _startMockStream();
  }

  Future<void> endSession() async {
    _mockTimer?.cancel();
    _mockTimer = null;

    final prev = state.value ?? const SessionState();
    state = AsyncData(
      prev.copyWith(
        isActive: false,
        riskScore: 0.0,
        currentSeverity: Severity.low,
      ),
    );
  }

  // Called by real WebSocket service when a frame response arrives
  void onEventReceived(DmsEvent event) {
    _applyEvent(event);
  }

  // ── Private ────────────────────────────────────────────────

  void _startMockStream() {
    // Fires a mock event every 2–5 seconds to simulate AI detections
    _scheduleMockEvent();
  }

  void _scheduleMockEvent() {
    final delay = Duration(milliseconds: 2000 + _rng.nextInt(3000));
    _mockTimer = Timer(delay, () {
      if (state.value?.isActive == true) {
        _emitMockEvent();
        _scheduleMockEvent(); // reschedule
      }
    });
  }

  void _emitMockEvent() {
    final type = _mockEventTypes[_rng.nextInt(_mockEventTypes.length)];
    // Weight towards lower severities for realistic feel
    final sevIndex = _weightedSeverityIndex();
    final severity = _mockSeverities[sevIndex];
    final confidence = 0.60 + _rng.nextDouble() * 0.39;

    final event = DmsEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      eventType: type,
      severity: severity,
      confidenceScore: confidence,
      timestamp: DateTime.now(),
      sessionId: state.value?.sessionId,
    );

    _applyEvent(event);
  }

  int _weightedSeverityIndex() {
    // LOW: 50%, MEDIUM: 30%, HIGH: 15%, CRITICAL: 5%
    final roll = _rng.nextDouble();
    if (roll < 0.50) return 0;
    if (roll < 0.80) return 1;
    if (roll < 0.95) return 2;
    return 3;
  }

  void _applyEvent(DmsEvent event) {
    final prev = state.value;
    if (prev == null || !prev.isActive) return;

    // Update recent events (cap at 20)
    final updated = [event, ...prev.recentEvents];
    if (updated.length > 20) updated.removeLast();

    // Update card state for this event type
    final cards = Map<EventType, EventCardState>.from(prev.cardStates);
    final existing = cards[event.eventType] ?? EventCardState(type: event.eventType);
    cards[event.eventType] = existing.copyWith(
      lastSeverity: event.severity,
      lastConfidence: event.confidenceScore,
      lastSeen: event.timestamp,
      countInSession: existing.countInSession + 1,
    );

    // Overall risk = highest severity seen in last 5 events, smoothed
    final recent5 = updated.take(5).toList();
    Severity worstRecent = Severity.low;
    for (final e in recent5) {
      if (e.severity.index > worstRecent.index) {
        worstRecent = e.severity;
      }
    }

    state = AsyncData(
      prev.copyWith(
        recentEvents: updated,
        cardStates: cards,
        currentSeverity: worstRecent,
        riskScore: worstRecent.riskScore,
      ),
    );
  }
}

// ─── Providers ─────────────────────────────────────────────────────────────────

final sessionProvider = AsyncNotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);