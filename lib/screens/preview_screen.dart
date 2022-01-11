import 'dart:convert';
import 'dart:io';

import 'package:color_analayzer/API_auth/recognizer.dart';
import 'package:color_analayzer/screens/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:color_analayzer/screens/captures_screen.dart';
import 'package:googleapis/vision/v1.dart';
import 'package:flutter/src/widgets/image.dart' as img;
import 'dart:io' as Io;


class PreviewScreen extends StatelessWidget {
  final File imageFile;
  final List<File> fileList;

  const PreviewScreen({
    required this.imageFile,
    required this.fileList,
  });

  Future<String?> getColorName() async{
    final bytes = await imageFile.readAsBytes();
    WebLabel? lable = await Recognizer().search(base64Encode(bytes));


    String? result = lable?.label ?? "No Lables";


    return result;

  }

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
                      child: img.Image.file(imageFile),
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
              FutureBuilder<String?>(
                future: getColorName(),
                initialData: 'Color_Name',
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    return
                      Center(
                        child: Text(
                          snapshot.data!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ],
        ),

    );
  }
}