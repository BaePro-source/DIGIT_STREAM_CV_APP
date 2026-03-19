import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../painters/mediapipe_pose_painter.dart';

class MediaPipePoseScreen extends StatefulWidget {
  const MediaPipePoseScreen({super.key});

  @override
  State<MediaPipePoseScreen> createState() => _MediaPipePoseScreenState();
}

class _MediaPipePoseScreenState extends State<MediaPipePoseScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isStreaming = false;
  bool _isDetecting = false;

  // 나중에 MediaPipe 결과를 여기에 넣을 예정
  List<Offset> _landmarks = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        debugPrint('사용 가능한 카메라가 없습니다.');
        return;
      }

      final CameraDescription selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });

      await _startImageStream();
    } catch (e) {
      debugPrint('카메라 초기화 오류: $e');
    }
  }

  Future<void> _startImageStream() async {
    if (_controller == null) return;
    if (_controller!.value.isStreamingImages) return;

    try {
      await _controller!.startImageStream((CameraImage image) async {
        if (_isDetecting) return;

        _isDetecting = true;

        try {
          // -------------------------------
          // TODO:
          // 여기서 나중에 MediaPipe 추론을 붙일 예정
          //
          // 예시 흐름:
          // 1. CameraImage -> MediaPipe 입력 형식 변환
          // 2. Pose detection 실행
          // 3. landmark 결과 받기
          // 4. setState(() { _landmarks = ...; })
          // -------------------------------

          // 지금은 UI 테스트 단계라 빈 값 유지
          if (mounted) {
            setState(() {
                _landmarks = [
                    const Offset(100, 200),
                    const Offset(200, 300),
                    const Offset(300, 400),
                ];
                });
          }
        } catch (e) {
          debugPrint('프레임 처리 오류: $e');
        } finally {
          _isDetecting = false;
        }
      });

      if (mounted) {
        setState(() {
          _isStreaming = true;
        });
      }
    } catch (e) {
      debugPrint('이미지 스트림 시작 오류: $e');
    }
  }

  Future<void> _stopImageStream() async {
    if (_controller == null) return;
    if (!_controller!.value.isStreamingImages) return;

    try {
      await _controller!.stopImageStream();

      if (mounted) {
        setState(() {
          _isStreaming = false;
        });
      }
    } catch (e) {
      debugPrint('이미지 스트림 중지 오류: $e');
    }
  }

  @override
  void dispose() {
    _stopImageStream();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pose Detection (MediaPipe)'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pose Detection (MediaPipe)'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),

          CustomPaint(
            size: Size.infinite,
            painter: MediaPipePosePainter(
              landmarks: _landmarks,
            ),
          ),

          Positioned(
            left: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _isStreaming
                    ? 'MediaPipe 준비 완료 (카메라 스트림 ON)'
                    : '카메라 스트림 OFF',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}