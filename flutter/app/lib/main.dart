import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'screens/live_digit_screen.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MNIST Stream CV App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LiveDigitScreen(),
    );
  }
}