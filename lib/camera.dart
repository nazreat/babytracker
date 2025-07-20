
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Camera extends StatefulWidget {
  const Camera({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  Future<File?> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      return File(pickedImage.path);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final imageFile = await pickImageFromGallery();
                if (imageFile != null) {
                  Navigator.pop<File?>(context, imageFile);
                }
              },
              child: Text('Select Image'),
            ),
          ],
        ),
      ),
    );
  }
}
