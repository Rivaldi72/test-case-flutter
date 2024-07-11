import 'package:flutter/material.dart';
import 'package:image_grid_app/pages/image_grid_page.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request storage permission when app start
  await _requestStoragePermission();

  runApp(const MyApp());
}

Future<void> _requestStoragePermission() async {
  var status = await Permission.manageExternalStorage.status;
  if (!status.isGranted) {
    await Permission.manageExternalStorage.request();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Grid App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ImageGridScreen(),
    );
  }
}
