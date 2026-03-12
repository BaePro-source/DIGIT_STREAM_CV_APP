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

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _controller = CameraController(   // 카메라를 실제로 조작하는 컨트롤러
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    // 초기화
    await _controller!.initialize();

    if (!mounted) return;
    setState(() {
      _isInitialized = true;
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
              //카메라 화면을 UI에 보여주는 위젯
              child: CameraPreview(_controller!),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: const Text(
                'Prediction Result: -',
                style: TextStyle(
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