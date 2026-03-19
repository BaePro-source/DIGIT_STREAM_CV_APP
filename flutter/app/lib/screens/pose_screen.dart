import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:gal/gal.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';

class PoseScreen extends StatefulWidget {
  const PoseScreen({super.key});

  @override
  State<PoseScreen> createState() => _PoseScreenState();
}

class _PoseScreenState extends State<PoseScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.base,
    ),
  );

  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;

  bool _isRecording = false;
  bool _isBusy = false;
  bool _isSwitchingCamera = false;

  Pose? _pose;
  Size? _imageSize;
  InputImageRotation? _rotation;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera({
    CameraLensDirection preferredLens = CameraLensDirection.front,
  }) async {
    _cameras = await availableCameras();

    for (final camera in _cameras) {
      debugPrint(
        'camera: ${camera.name}, lensDirection: ${camera.lensDirection}, sensorOrientation: ${camera.sensorOrientation}',
      );
    }

    if (_cameras.isEmpty) return;

    final selectedIndex = _cameras.indexWhere(
      (camera) => camera.lensDirection == preferredLens,
    );

    _cameraIndex = selectedIndex >= 0 ? selectedIndex : 0;

    await _setupCamera(_cameras[_cameraIndex]);
  }

  Future<void> _setupCamera(CameraDescription cameraDescription) async {
    final oldController = _controller;

    if (oldController != null) {
      try {
        if (oldController.value.isStreamingImages) {
          await oldController.stopImageStream();
        }
      } catch (_) {}

      await oldController.dispose();
    }

    final controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    _controller = controller;
    _initializeControllerFuture = controller.initialize();

    await _initializeControllerFuture;

    _imageSize = Size(
      controller.value.previewSize!.height,
      controller.value.previewSize!.width,
    );

    _rotation = _inputImageRotationFromCamera(
      cameraDescription.sensorOrientation,
    );

    await controller.startImageStream(_processCameraImage);

    if (mounted) {
      setState(() {});
    }
  }

  InputImageRotation _inputImageRotationFromCamera(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      case 0:
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isBusy) return;
    if (_controller == null) return;

    _isBusy = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();

      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }

      final bytes = allBytes.done().buffer.asUint8List();

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: _rotation ?? InputImageRotation.rotation0deg,
          format: Platform.isAndroid
              ? InputImageFormat.nv21
              : InputImageFormat.bgra8888,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );

      final poses = await _poseDetector.processImage(inputImage);

      if (!mounted) return;

      setState(() {
        _pose = poses.isNotEmpty ? poses.first : null;
      });
    } catch (e) {
      debugPrint('Pose detection error: $e');
    } finally {
      _isBusy = false;
    }
  }

  Future<void> _switchCamera() async {
    if (_controller == null) return;
    if (_isSwitchingCamera) return;

    _isSwitchingCamera = true;

    try {
      final currentLens = _controller!.description.lensDirection;

      final targetLens = currentLens == CameraLensDirection.front
          ? CameraLensDirection.back
          : CameraLensDirection.front;

      final targetIndex = _cameras.indexWhere(
        (camera) => camera.lensDirection == targetLens,
      );

      if (targetIndex == -1) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('전환할 카메라를 찾지 못했어요.')),
          );
        }
        return;
      }

      _cameraIndex = targetIndex;
      _pose = null;

      if (mounted) {
        setState(() {});
      }

      await _setupCamera(_cameras[_cameraIndex]);
    } catch (e) {
      debugPrint('Camera switch error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카메라 전환 중 오류가 발생했어요.')),
        );
      }
    } finally {
      _isSwitchingCamera = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

Future<void> _startRecording() async {
  bool started = await FlutterScreenRecording.startRecordScreen("pose_record");

  if (started) {
    setState(() {
      _isRecording = true;
    });
  }
}

Future<void> _stopRecording() async {
  String path = await FlutterScreenRecording.stopRecordScreen;

  if (!mounted) return;

  try {
    // 권한 확인
    bool hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      await Gal.requestAccess();
    }

    // 🔥 갤러리에 저장
    await Gal.putVideo(path);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('갤러리에 저장 완료')),
    );
  } catch (e) {
    debugPrint('갤러리 저장 실패: $e');
  }

  setState(() {
    _isRecording = false;
  });

  debugPrint('saved path: $path');
}

  @override
  void dispose() {
    final controller = _controller;
    _controller = null;

    if (controller != null) {
      try {
        if (controller.value.isStreamingImages) {
          controller.stopImageStream();
        }
      } catch (_) {}
      controller.dispose();
    }

    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _initializeControllerFuture == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done ||
              _isSwitchingCamera) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(_controller!),

              if (_pose != null && _imageSize != null)
                CustomPaint(
                  painter: PosePainter(
                    pose: _pose!,
                    imageSize: _imageSize!,
                    isFrontCamera:
                        _controller!.description.lensDirection ==
                        CameraLensDirection.front,
                  ),
                ),

              Positioned(
                top: 50,
                left: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCircleButton(
                      icon: Icons.cameraswitch,
                      onTap: _switchCamera,
                    ),
                    _buildCircleButton(
                      icon: _isRecording ? Icons.stop : Icons.fiber_manual_record,
                      backgroundColor: _isRecording ? Colors.red : Colors.white,
                      iconColor: _isRecording ? Colors.white : Colors.red,
                      onTap: _isRecording ? _stopRecording : _startRecording,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color backgroundColor = Colors.white,
    Color iconColor = Colors.black,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 30),
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  final Pose pose;
  final Size imageSize;
  final bool isFrontCamera;

  PosePainter({
    required this.pose,
    required this.imageSize,
    required this.isFrontCamera,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 6
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    Offset transform(PoseLandmark landmark) {
      double x = landmark.x * size.width / imageSize.width;
      double y = landmark.y * size.height / imageSize.height;

     /* if (isFrontCamera) {
        x = size.width - x;
      } */

      return Offset(x, y);
    }

    void drawLine(PoseLandmarkType a, PoseLandmarkType b) {
      final landmarkA = pose.landmarks[a];
      final landmarkB = pose.landmarks[b];

      if (landmarkA != null && landmarkB != null) {
        canvas.drawLine(transform(landmarkA), transform(landmarkB), linePaint);
      }
    }

    void drawPoint(PoseLandmarkType type) {
      final landmark = pose.landmarks[type];
      if (landmark != null) {
        canvas.drawCircle(transform(landmark), 4, pointPaint);
      }
    }

    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
    drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);

    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
    drawLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);

    drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
    drawLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);

    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
    drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);

    drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
    drawLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);

    drawLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
    drawLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);

    for (final type in PoseLandmarkType.values) {
      drawPoint(type);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.pose != pose ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.isFrontCamera != isFrontCamera;
  }
}