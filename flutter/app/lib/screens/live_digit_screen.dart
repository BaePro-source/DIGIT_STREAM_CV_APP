import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../main.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class LiveDigitScreen extends StatefulWidget {
  const LiveDigitScreen({super.key});

  @override
  State<LiveDigitScreen> createState() => _LiveDigitScreenState();
}

class _LiveDigitScreenState extends State<LiveDigitScreen> {
  CameraController? _controller;
  bool _isInitialized = false;

  bool _isProcessing = false;
  String _prediction = '-';
  DateTime _lastProcessed = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();

    if (!mounted) return;
    setState(() {
      _isInitialized = true;
    });

    await _startImageStream();
  }

  Future<void> _startImageStream() async {
    if (_controller == null) return;
    if (_controller!.value.isStreamingImages) return;

    await _controller!.startImageStream((CameraImage image) async {
      final now = DateTime.now();

      if (_isProcessing) return;
      if (now.difference(_lastProcessed).inMilliseconds < 1000) return;

      _isProcessing = true;
      _lastProcessed = now;
 
      try {
        final pngBytes = _convertCameraImageToPng(image);
        final result = await ApiService.sendImage(pngBytes);

        if (!mounted) return;
        setState(() {
          _prediction = result.toString();
        });
      } catch (e) {
        debugPrint('Prediction error: $e');

        if (!mounted) return;
        setState(() {
          _prediction = 'Error: $e';
        });
      } finally {
        _isProcessing = false;
      }
    });
  }

  Uint8List _convertCameraImageToPng(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    final plane = image.planes[0];
    final bytes = plane.bytes;
    final bytesPerRow = plane.bytesPerRow;
    final bytesPerPixel = plane.bytesPerPixel ?? 4;

    final converted = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      final rowOffset = y * bytesPerRow;

      for (int x = 0; x < width; x++) {
        final pixelOffset = rowOffset + x * bytesPerPixel;

        if (pixelOffset + 3 >= bytes.length) continue;

        final b = bytes[pixelOffset];
        final g = bytes[pixelOffset + 1];
        final r = bytes[pixelOffset + 2];
        final a = bytes[pixelOffset + 3];

        converted.setPixelRgba(x, y, r, g, b, a);
      }
    }

    return Uint8List.fromList(img.encodePng(converted));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MNIST Stream CV App'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: CameraPreview(_controller!),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                _isProcessing ? 'Processing...' : _prediction,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}