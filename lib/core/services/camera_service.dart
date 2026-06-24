import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

/// Manages the device camera lifecycle.
/// - Always picks the FRONT camera (driver-facing)
/// - Captures frames at 10 FPS as Base64-encoded JPEG
/// - Exposes a stream of Base64 strings → feed directly into WebSocket
class CameraService {
  CameraController? _controller;
  Timer? _frameTimer;
  final _frameStreamController = StreamController<String>.broadcast();

  bool _isCapturing = false;

  // ── Public getters ─────────────────────────────────────────

  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;
  bool get isCapturing => _isCapturing;

  /// Stream of Base64-encoded JPEG frames at ~10 FPS.
  /// Subscribe in WebSocketService and send each frame to friend's server.
  Stream<String> get frameStream => _frameStreamController.stream;

  // ── Lifecycle ──────────────────────────────────────────────

  /// Call this on session start.
  /// Returns null on success, error message string on failure.
  Future<String?> initialize() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return 'No cameras found on this device.';

      // Always pick front camera for driver monitoring
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first, // fallback to any camera
      );

      _controller = CameraController(
        front,
        ResolutionPreset.medium, // 480p — good balance for AI + bandwidth
        enableAudio: false,       // driver monitoring doesn't need audio
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      return null; // success
    } on CameraException catch (e) {
      return 'Camera error: ${e.description}';
    } catch (e) {
      return 'Failed to initialize camera: $e';
    }
  }

  /// Start capturing frames at 10 FPS.
  void startCapture() {
    if (!isInitialized || _isCapturing) return;
    _isCapturing = true;

    // 10 FPS = 1 frame every 100ms
    _frameTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _captureFrame();
    });
  }

  /// Stop frame capture but keep controller alive (preview still shows).
  void stopCapture() {
    _frameTimer?.cancel();
    _frameTimer = null;
    _isCapturing = false;
  }

  /// Full teardown — call on session end.
  Future<void> dispose() async {
    stopCapture();
    await _controller?.dispose();
    _controller = null;
  }

  /// Close the frame stream — call only when the app is fully done with camera.
  void closeStream() {
    _frameStreamController.close();
  }

  // ── Private ────────────────────────────────────────────────

  Future<void> _captureFrame() async {
    if (_controller == null || !isInitialized || _isCapturing == false) return;

    try {
      // takePicture() gives a full JPEG — lightweight enough at medium preset
      final XFile file = await _controller!.takePicture();
      final bytes = await file.readAsBytes();
      final base64Frame = base64Encode(bytes);

      if (!_frameStreamController.isClosed) {
        _frameStreamController.add(base64Frame);
      }
    } catch (e) {
      // Skip this frame silently — next timer tick will try again
      debugPrint('[CameraService] Frame capture error: $e');
    }
  }
}