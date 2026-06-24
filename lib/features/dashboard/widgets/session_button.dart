import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/camera_provider.dart';
import 'camera_preview_widget.dart';

/// Start/End session button with real camera preview.
/// Camera starts when session starts, stops when session ends.
class SessionButton extends ConsumerStatefulWidget {
  final bool isActive;
  final VoidCallback onStart;
  final VoidCallback onEnd;

  const SessionButton({
    super.key,
    required this.isActive,
    required this.onStart,
    required this.onEnd,
  });

  @override
  ConsumerState<SessionButton> createState() => _SessionButtonState();
}

class _SessionButtonState extends ConsumerState<SessionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _liveAnim;

  @override
  void initState() {
    super.initState();
    _liveAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _liveAnim.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.isActive) {
      // Stop camera first, then end session
      await ref.read(cameraProvider.notifier).stopCamera();
      widget.onEnd();
    } else {
      // Start session first, then start camera
      widget.onStart();
      await ref.read(cameraProvider.notifier).startCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Camera preview area ────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          height: widget.isActive ? 200 : 0,
          child: widget.isActive
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CameraPreviewWidget(liveAnim: _liveAnim),
                )
              : const SizedBox.shrink(),
        ),
        if (widget.isActive) const SizedBox(height: 12),

        // ── Start / End button ─────────────────────────────────
        GestureDetector(
          onTap: _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: widget.isActive
                  ? const LinearGradient(
                      colors: [Color(0xFFFF1744), Color(0xFFFF6D00)],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                    ),
              boxShadow: [
                BoxShadow(
                  color: widget.isActive
                      ? const Color(0xFFFF1744).withValues(alpha: 0.35)
                      : const Color(0xFF00E676).withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isActive) ...[
                  AnimatedBuilder(
                    animation: _liveAnim,
                    builder: (_, __) => Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white
                            .withValues(alpha: 0.4 + _liveAnim.value * 0.6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  widget.isActive ? 'END SESSION' : 'START SESSION',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}