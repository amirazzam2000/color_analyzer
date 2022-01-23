import 'dart:io';

import 'package:camera/camera.dart';
import 'package:color_analayzer/screens/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:color_analayzer/screens/preview_screen.dart';
import 'package:image_picker/image_picker.dart';

class CapturesScreen extends StatelessWidget {
  final List<File> imageFileList;

  CapturesScreen({Key? key, required this.imageFileList}) : super(key: key);
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    return image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
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
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => FutureBuilder<XFile?>(
                              future: pickImage(),
                              //initialData: 'Color_Name',
                              builder: (context, snapshot) {
                                if(snapshot.hasData){
                                  return PreviewScreen(
                                    fileList: imageFileList,
                                    imageFile: File(snapshot.data!.path),
                                  );
                                }else{
                                  return CapturesScreen(imageFileList: imageFileList,);
                                }
                              }
                          )
                        ),
                      );
                    },
                    child: Icon(Icons.image , size: 20),
                    style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.deepPurple,
                        textStyle: const TextStyle(fontSize: 20)
                    ),
                  ),
                ]
              )
            ),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              children: [
                for (File imageFile in imageFileList)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => PreviewScreen(
                              fileList: imageFileList,
                              imageFile: imageFile,
                            ),
                          ),
                        );
                      },
                      child: Image.file(
                        imageFile,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}