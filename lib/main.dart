import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'theme/app_theme.dart';
import 'screens/scanner_screen.dart';
import 'services/ocr_service.dart';
import 'services/barcode_service.dart';

Future<void> main() async {
  // Preserve the native splash screen
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  CameraController? initialController;

  try {
    // Hardware Initialization Logic
    OcrService(); // ML Kit setup
    BarcodeService(); // ML Kit setup

    if (!kIsWeb) {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        final cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          initialController = CameraController(
            cameras[0],
            ResolutionPreset.high,
            enableAudio: false,
          );
          await initialController.initialize();
        }
      }
    } else {
      // Web initialization
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        initialController = CameraController(
          cameras[0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await initialController.initialize();
      }
    }
  } catch (e) {
    debugPrint('Hardware initialization error: $e');
  } finally {
    // Call remove() only after camera has successfully initialized 
    // or the catch block is triggered.
    FlutterNativeSplash.remove();
  }
  
  // Ensure status bar is transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(SafeScanApp(initialController: initialController));
}

class SafeScanApp extends StatelessWidget {
  final CameraController? initialController;
  
  const SafeScanApp({super.key, this.initialController});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Scan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: ScannerScreen(initialController: initialController),
    );
  }
}
