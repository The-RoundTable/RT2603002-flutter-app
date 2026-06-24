import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/camera_provider.dart';

/// Real camera preview widget.
/// Handles all camera states: initializing, permission denied, error, live feed.
/// Drop this directly into session_button.dart replacing _CameraPlaceholder.
class CameraPreviewWidget extends ConsumerWidget {
  final AnimationController liveAnim;

  const CameraPreviewWidget({super.key, required this.liveAnim});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraAsync = ref.watch(cameraProvider);

    return cameraAsync.when(
      loading: () => _buildLoading(),
      error: (e, _) => _buildError(e.toString()),
      data: (cameraState) {
        switch (cameraState.status) {
          case CameraStatus.idle:
            return _buildIdle();

          case CameraStatus.initializing:
            return _buildLoading();

          case CameraStatus.permissionDenied:
            return _buildPermissionDenied();

          case CameraStatus.error:
            return _buildError(cameraState.errorMessage ?? 'Unknown error');

          case CameraStatus.ready:
          case CameraStatus.capturing:
            final controller = cameraState.controller;
            if (controller == null || !controller.value.isInitialized) {
              return _buildLoading();
            }
            return _buildLiveFeed(controller, cameraState.status);
        }
      },
    );
  }

  // ── Live feed ──────────────────────────────────────────────

  Widget _buildLiveFeed(CameraController controller, CameraStatus status) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Real camera preview ──────────────────────────
          ClipRect(
            child: OverflowBox(
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.previewSize?.height ?? 480,
                  height: controller.value.previewSize?.width ?? 640,
                  child: CameraPreview(controller),
                ),
              ),
            ),
          ),

          // ── Scan line overlay ────────────────────────────
          const _ScanLineOverlay(),

          // ── LIVE badge ────────────────────────────────────
          Positioned(
            top: 10,
            left: 10,
            child: _LiveBadge(
              liveAnim: liveAnim,
              isCapturing: status == CameraStatus.capturing,
            ),
          ),

          // ── Corner brackets ───────────────────────────────
          ..._buildCornerBrackets(),
        ],
      ),
    );
  }

  // ── State screens ──────────────────────────────────────────

  Widget _buildLoading() {
    return _StateContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Color(0xFF00E676),
              strokeWidth: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Starting camera...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdle() {
    return _StateContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.videocam_outlined,
            color: Colors.white.withValues(alpha: 0.15),
            size: 36,
          ),
          const SizedBox(height: 8),
          Text(
            'Camera ready',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return _StateContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.no_photography_outlined,
              color: Color(0xFFFF6D00), size: 32),
          const SizedBox(height: 10),
          const Text(
            'Camera Permission Denied',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF6D00),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Go to Settings → App → Permissions\nand enable Camera.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.35),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return _StateContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF1744), size: 32),
          const SizedBox(height: 10),
          const Text(
            'Camera Error',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF1744),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  // ── Corner brackets ────────────────────────────────────────

  List<Widget> _buildCornerBrackets() {
    const color = Color(0xFF00E676);

    Widget bracket(AlignmentGeometry align, bool flipX, bool flipY) {
      return Positioned.fill(
        child: Align(
          alignment: align,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Transform.scale(
              scaleX: flipX ? -1 : 1,
              scaleY: flipY ? -1 : 1,
              child: SizedBox(
                width: 18,
                height: 18,
                child: CustomPaint(
                  painter: _BracketPainter(
                    color: color.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return [
      bracket(Alignment.topLeft, false, false),
      bracket(Alignment.topRight, true, false),
      bracket(Alignment.bottomLeft, false, true),
      bracket(Alignment.bottomRight, true, true),
    ];
  }
}

// ─── Supporting Widgets ────────────────────────────────────────────────────────

class _StateContainer extends StatelessWidget {
  final Widget child;
  const _StateContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0A0A0F),
      child: Center(child: child),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final AnimationController liveAnim;
  final bool isCapturing;

  const _LiveBadge({required this.liveAnim, required this.isCapturing});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: liveAnim,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFF1744)
              .withValues(alpha: 0.15 + liveAnim.value * 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color(0xFFFF1744).withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF1744).withValues(
                  alpha: isCapturing ? 0.5 + liveAnim.value * 0.5 : 0.3,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              isCapturing ? 'LIVE' : 'CAMERA',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Color(0xFFFF1744),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Subtle animated scan line — gives the AI monitoring feel
class _ScanLineOverlay extends StatefulWidget {
  const _ScanLineOverlay();

  @override
  State<_ScanLineOverlay> createState() => _ScanLineOverlayState();
}

class _ScanLineOverlayState extends State<_ScanLineOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pos;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _pos = Tween<double>(begin: 0, end: 1).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pos,
      builder: (context, _) {
        return Positioned(
          top: _pos.value * 200, // moves across the 200px preview height
          left: 0,
          right: 0,
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF00E676).withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BracketPainter extends CustomPainter {
  final Color color;
  _BracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(_BracketPainter old) => false;
}