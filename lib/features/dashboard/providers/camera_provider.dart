import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/camera_service.dart';

// ─── Camera State ──────────────────────────────────────────────────────────────

enum CameraStatus {
  idle,           // session not started
  initializing,   // waiting for permission + controller init
  ready,          // controller initialized, preview visible
  capturing,      // actively sending frames
  error,          // something went wrong
  permissionDenied,
}

class CameraState {
  final CameraStatus status;
  final String? errorMessage;
  final CameraController? controller;

  const CameraState({
    this.status = CameraStatus.idle,
    this.errorMessage,
    this.controller,
  });

  bool get isActive =>
      status == CameraStatus.ready || status == CameraStatus.capturing;

  CameraState copyWith({
    CameraStatus? status,
    String? errorMessage,
    CameraController? controller,
  }) {
    return CameraState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      controller: controller ?? this.controller,
    );
  }
}

// ─── Camera Notifier ───────────────────────────────────────────────────────────

class CameraNotifier extends AsyncNotifier<CameraState> {
  late final CameraService _service;

  @override
  Future<CameraState> build() async {
    _service = CameraService();

    // Cleanup when provider is disposed
    ref.onDispose(() async {
      await _service.dispose();
      _service.closeStream();
    });

    return const CameraState();
  }

  // ── Public API ─────────────────────────────────────────────

  /// Call on session start — initializes camera and begins frame capture.
  Future<void> startCamera() async {
    state = AsyncData(
      const CameraState(status: CameraStatus.initializing),
    );

    final error = await _service.initialize();

    if (error != null) {
      // Distinguish permission denial from other errors
      final isPermission = error.toLowerCase().contains('denied') ||
          error.toLowerCase().contains('permission');

      state = AsyncData(
        CameraState(
          status: isPermission
              ? CameraStatus.permissionDenied
              : CameraStatus.error,
          errorMessage: error,
        ),
      );
      return;
    }

    state = AsyncData(
      CameraState(
        status: CameraStatus.ready,
        controller: _service.controller,
      ),
    );

    // Start capturing frames immediately
    _service.startCapture();

    state = AsyncData(
      CameraState(
        status: CameraStatus.capturing,
        controller: _service.controller,
      ),
    );
  }

  /// Call on session end — stops capture and releases camera.
  Future<void> stopCamera() async {
    await _service.dispose();
    state = const AsyncData(CameraState(status: CameraStatus.idle));
  }

  /// Expose the raw frame stream for WebSocketService to subscribe to.
  /// Usage: ref.read(cameraProvider.notifier).frameStream
  Stream<String> get frameStream => _service.frameStream;
}

// ─── Providers ─────────────────────────────────────────────────────────────────

final cameraProvider = AsyncNotifierProvider<CameraNotifier, CameraState>(
  CameraNotifier.new,
);