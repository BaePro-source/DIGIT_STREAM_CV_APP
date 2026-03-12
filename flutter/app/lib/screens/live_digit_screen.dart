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
      if (now.difference(_lastProcessed).inMilliseconds < 500) return;

      _isProcessing = true;
      _lastProcessed = now;

      try {
        final result = await _fakePredict(image);

        if (!mounted) return;
        setState(() {
          _prediction = result;
        });
      } catch (e) {
        debugPrint('Prediction error: $e');
      } finally {
        _isProcessing = false;
      }
    });
  }

  Future<String> _fakePredict(CameraImage image) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return 'Predicted Digit: 5';
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