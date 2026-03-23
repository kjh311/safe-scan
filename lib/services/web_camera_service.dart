/// Web-only camera service using package:web and dart:js_interop to directly
/// call navigator.mediaDevices.getUserMedia, bypassing the camera plugin.
library;

import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

class WebCameraService {
  web.HTMLVideoElement? _videoElement;
  bool _isInitialized = false;
  static const String _containerId = 'web-camera-container';

  bool get isInitialized => _isInitialized;

  /// Requests camera access and streams the feed into a video element.
  Future<bool> initialize() async {
    if (!kIsWeb) return false;
    try {
      final constraints = web.MediaStreamConstraints(
        video: true.toJS,
        audio: false.toJS,
      );

      final stream = await web.window.navigator.mediaDevices
          .getUserMedia(constraints)
          .toDart;

      _videoElement = web.HTMLVideoElement()
        ..srcObject = stream
        ..autoplay = true
        ..muted = true
        ..style.setProperty("object-fit", "cover")
        ..style.setProperty("width", "100%")
        ..style.setProperty("height", "100%")
        ..style.setProperty("position", "absolute")
        ..style.setProperty("top", "0")
        ..style.setProperty("left", "0")
        ..style.setProperty("z-index", "0")
        ..style.setProperty("pointer-events", "none")
        ..style.setProperty("transform", "scaleX(-1)"); // Mirror for selfie cam

      // Create container if it doesn't exist
      _ensureContainerExists();

      // Append video to the container
      final container = web.document.getElementById(_containerId);
      container?.append(_videoElement!);

      // Wait for the video to be ready to play
      final completer = Completer<void>();
      _videoElement!.oncanplay = ((web.Event e) {
        if (!completer.isCompleted) completer.complete();
      }).toJS;
      await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => debugPrint('[WebCamera] Video ready timeout.'),
      );

      _isInitialized = true;
      debugPrint('[WebCamera] Camera stream initialized via MediaDevices API.');
      return true;
    } catch (e) {
      debugPrint('[WebCamera] Failed to get camera stream: $e');
      return false;
    }
  }

  void _ensureContainerExists() {
    // Always remove existing container to ensure fresh styles
    final existingContainer = web.document.getElementById(_containerId);
    if (existingContainer != null) {
      existingContainer.remove();
    }

    final container = web.HTMLDivElement()
      ..id = _containerId
      ..style.setProperty("position", "absolute")
      ..style.setProperty("top", "0")
      ..style.setProperty("left", "0")
      ..style.setProperty("width", "100%")
      ..style.setProperty("height", "100%")
      ..style.setProperty("z-index", "0")
      ..style.setProperty("overflow", "hidden");

    // Insert as first child of body to ensure it's behind other content
    final body = web.document.body;
    if (body != null) {
      body.insertBefore(container, body.firstChild);
    } else {
      web.document.body?.append(container);
    }
  }

  /// Captures a single frame from the video stream as a data URL.
  Future<String?> captureFrame() async {
    if (!_isInitialized || _videoElement == null) return null;
    try {
      final canvas = web.HTMLCanvasElement()
        ..width = _videoElement!.videoWidth
        ..height = _videoElement!.videoHeight;

      final ctx = canvas.getContext('2d') as web.CanvasRenderingContext2D?;
      if (ctx != null) {
        // Flip canvas horizontally to account for mirrored video
        ctx.translate(canvas.width.toDouble(), 0);
        ctx.scale(-1, 1);
        ctx.drawImage(_videoElement!, 0, 0);
      }

      // Use toDataURL for simpler cross-browser compatibility
      final dataUrl = canvas.toDataURL('image/jpeg', 0.95.toJS);
      debugPrint('[WebCamera] Frame captured as data URL.');
      return dataUrl;
    } catch (e) {
      debugPrint('[WebCamera] Frame capture error: $e');
      return null;
    }
  }

  void dispose() {
    if (_videoElement != null) {
      final stream = _videoElement!.srcObject as web.MediaStream?;
      stream?.getTracks().toDart.forEach((track) => track.stop());
      _videoElement!.remove();
      _videoElement = null;
    }
    _isInitialized = false;
    debugPrint('[WebCamera] Camera stream disposed.');
  }
}
