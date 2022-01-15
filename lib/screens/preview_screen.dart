import 'dart:convert';
import 'dart:core';
import 'dart:core' as core;
import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:color_analayzer/API_auth/recognizer.dart';
import 'package:color_analayzer/Colors/color_data_object.dart';
import 'package:color_analayzer/Colors/color_manager.dart';
import 'package:color_analayzer/Data/defaults.dart';
import 'package:color_analayzer/screens/camera_screen.dart';
import 'package:color_analayzer/screens/scheme_loader.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:color_analayzer/screens/captures_screen.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/vision/v1.dart';
import 'package:flutter/src/widgets/image.dart' as img;
import 'package:flutter/material.dart' as f;
import 'dart:io' as Io;

import 'expandable_colors.dart';




class PreviewScreen extends StatelessWidget {
  final File imageFile;
  final List<File> fileList;

  PreviewScreen({
    required this.imageFile,
    required this.fileList,
  });

  Future<Map<String, dynamic>> getColorName() async{
    print("requesting info");

    final bytes = await imageFile.readAsBytes();
    List<ColorDataObject> label = (await Recognizer().search(base64Encode(bytes)));
    label.sort((ColorDataObject a, ColorDataObject b ) => ((b.score * 100) -  (a.score * 100) ).round());

    var color = label[0];


    Map<String, dynamic> results = {
      "DominantColorList" : label,
      "DominantColor" : color,
    };

    return results;
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
              FutureBuilder<Map<String, dynamic>>(
                future: getColorName(),
                //initialData: 'Color_Name',
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    return DraggableScrollableSheet(
                      initialChildSize: 0.1,
                      maxChildSize: 1,
                      minChildSize: 0.1,
                      builder:
                          (BuildContext context, ScrollController scrollController) {
                        return Container(
                          decoration: BoxDecoration(
                              //color: ui.Color(0xFFCAA7FD),
                              color: ui.Color.fromRGBO(
                                  snapshot.data!["DominantColor"].rgb.red  - 80 ,
                                  snapshot.data!["DominantColor"].rgb.green - 80,
                                  snapshot.data!["DominantColor"].rgb.blue  - 80,
                                  1
                              ),
                              borderRadius: const BorderRadius.vertical(top: (Radius.circular(20))
                              )
                          ),

                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: 1,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(

                                children:  [
                                  Container(
                                      decoration: const BoxDecoration(
                                          color: Colors.deepPurple,
                                          borderRadius: BorderRadius.vertical(top: (Radius.circular(20))
                                          )
                                      ),
                                      height: 80,

                                      child: Center(
                                          child: Container(
                                            child:
                                            const Icon(
                                              Icons.expand_less_rounded ,
                                              size: 28,
                                              color: Colors.white,
                                            ),
                                          )
                                      )
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB( 0, 30, 0, 0,),
                                    child: Text(
                                      "Dominant Colors: ",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ExpandableColorPallet(
                                    colors: snapshot.data!["DominantColorList"],
                                  ),

                                  const Padding(
                                    padding: EdgeInsets.fromLTRB( 0, 30, 0, 0,),
                                    child: Text(
                                      "Color Schemes: ",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ExpandableColorScheme(
                                    schemeName: 'monochrome',
                                    color: snapshot.data!["DominantColor"],

                                  ),

                                  ExpandableColorScheme(
                                    schemeName: 'monochrome-dark',
                                    color: snapshot.data!["DominantColor"],

                                  ),

                                  ExpandableColorScheme(
                                    schemeName: 'monochrome-light',
                                    color: snapshot.data!["DominantColor"],

                                  ),

                                  ExpandableColorScheme(
                                    schemeName: 'analogic',
                                    color: snapshot.data!["DominantColor"],

                                  ),

                                  ExpandableColorScheme(
                                    schemeName: 'complement',
                                    color: snapshot.data!["DominantColor"],

                                  ),

                                  ExpandableColorScheme(
                                    schemeName: 'analogic-complement',
                                    color: snapshot.data!["DominantColor"],

                                  ),

                                  ExpandableColorScheme(
                                    schemeName: 'triad',
                                    color: snapshot.data!["DominantColor"],

                                  ),

                                  ExpandableColorScheme(
                                    schemeName: 'quad',
                                    color: snapshot.data!["DominantColor"],

                                  ),

                                ],
                              );
                            },
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
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