import 'dart:io';

import 'package:color_analayzer/screens/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:color_analayzer/screens/captures_screen.dart';

class PreviewScreen extends StatelessWidget {
  final File imageFile;
  final List<File> fileList;

  const PreviewScreen({
    required this.imageFile,
    required this.fileList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Image.file(imageFile),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => CameraScreen(),
                      ),
                    );
                  },
                  child: RichText(
                      text: const TextSpan(
                        children: [
                          WidgetSpan(
                            child: Icon(Icons.arrow_back, size: 14),
                          ),
                          TextSpan(
                            text: 'Back',
                          ),
                        ],
                      ),

                  ),
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.deepPurple,
                    textStyle: const TextStyle(fontSize: 20)
                  ),
                ),
              ),
            ],
        ),

    );
  }
}