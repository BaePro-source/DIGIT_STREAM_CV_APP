import 'package:flutter/material.dart';
import 'live_digit_screen.dart';
import 'pose_screen.dart';
import 'mediapipe_pose_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CV App Home'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LiveDigitScreen(),
                  ),
                );
              },
              child: const Text('실시간 숫자 인식'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PoseScreen(),
                  ),
                );
              },
              child: const Text('Pose Detection (ML Kit)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MediaPipePoseScreen(),
                  ),
                );
              },
              child: const Text('Pose Detection (MediaPipe)'),
            ),
          ],
        ),
      ),
    );
  }
}