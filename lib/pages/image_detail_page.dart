import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

class ImageDetailScreen extends StatefulWidget {
  final String imageUrl;

  const ImageDetailScreen({super.key, required this.imageUrl});

  @override
  _ImageDetailScreenState createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  File? _logoImage;
  String _text = '';
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _logoImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveImage() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      // Requesting storage permission again if the user not allowed permission when app start
      status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Permission denied')));
        return;
      }
    }

    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final imgFile = File('${directory.path}/saved_image.png');
      await imgFile.writeAsBytes(pngBytes);

      if (await imgFile.exists()) {
        await GallerySaver.saveImage(imgFile.path, albumName: 'ImageGridApp');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image saved to gallery')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Image file not saved')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saving image: $e')));
    }
  }

  Future<void> _shareImage() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    final directory = await getApplicationDocumentsDirectory();
    final imgFile = File('${directory.path}/shared_image.png');
    await imgFile.writeAsBytes(pngBytes);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Share Image to'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  _shareToFacebook(imgFile.path);
                  Navigator.of(context).pop();
                },
                child: const Text('Facebook'),
              ),
              ElevatedButton(
                onPressed: () {
                  _shareToTwitter(imgFile.path);
                  Navigator.of(context).pop();
                },
                child: const Text('Twitter'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareToFacebook(String imagePath) async {
    await Share.shareXFiles([XFile(imagePath)], text: 'Check out this image!');
  }

  Future<void> _shareToTwitter(String imagePath) async {
    await Share.shareXFiles([XFile(imagePath)],
        text: 'Check out this image!', subject: 'Subject');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Detail'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _globalKey,
              child: Stack(
                children: [
                  Image.network(widget.imageUrl, fit: BoxFit.cover),
                  if (_logoImage != null)
                    Positioned(
                      top: 10,
                      left: 0,
                      child: Image.file(
                        _logoImage!,
                        width: 200,
                        height: 200,
                      ),
                    ),
                  if (_text.isNotEmpty)
                    Positioned(
                      top: 10,
                      left: 160,
                      child: Text(
                        _text,
                        style: const TextStyle(
                            fontSize: 30,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _pickLogo,
                child: const Text('Add Logo'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      String inputText = '';
                      return AlertDialog(
                        title: const Text('Add Text'),
                        content: TextField(
                          onChanged: (value) {
                            inputText = value;
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, inputText);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );

                  if (result != null && result.isNotEmpty) {
                    setState(() {
                      _text = result;
                    });
                  }
                },
                child: const Text('Add Text'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _saveImage,
                child: const Text('Save'),
              ),
              ElevatedButton(
                onPressed: _shareImage,
                child: const Text('Share'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
