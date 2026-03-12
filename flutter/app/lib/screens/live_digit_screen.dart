import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class LiveDigitScreen extends StatefulWidget {
  const LiveDigitScreen({super.key});

  @override
  State<LiveDigitScreen> createState() => _LiveDigitScreenState();
}

class _LiveDigitScreenState extends State<LiveDigitScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isStreaming = false;
  int _frameCount = 0;
  String _prediction = '-';

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

    await _controller!.startImageStream((CameraImage image) {
      _frameCount++;

      if (_frameCount % 10 == 0) {
        if (!mounted) return;
        setState(() {
          _isStreaming = true;
          _prediction =
              'Streaming... ${image.width} x ${image.height} / frames: $_frameCount';
        });
      }
    });
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
                _isStreaming
                    ? _prediction
                    : 'Prediction Result: waiting for stream...',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
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