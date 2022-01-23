import 'dart:io';

import 'package:color_analayzer/Colors/color_data_object.dart';
import 'package:color_analayzer/screens/expandable_colors.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import 'package:share_plus/share_plus.dart';

class SaveShare {
  static List<Widget> getColorBox(List<ColorDataObject> colors) {
    List<Widget> widgets = <Widget>[];
    colors.sort((ColorDataObject a, ColorDataObject b ) => ((b.score * 100) -  (a.score * 100) ).round());
    for (int i = 0; i < colors.length; i++) {
      widgets.add(
          Expanded(
            child: Container(
              color: Color.fromRGBO(
                  colors[i].rgb.red.round(),
                  colors[i].rgb.green.round(),
                  colors[i].rgb.blue.round(),
                  1
              ),
            ),
            flex: (colors[i].score* 100).round(),

          )
      );
    }

    return widgets;
  }

  static void SendAsImage(List<ColorDataObject> colors) async{

    ScreenshotController screenshotController = ScreenshotController();
    final directory = (await getApplicationDocumentsDirectory ()).path;

    screenshotController
        .captureFromWidget(
            /*MediaQuery(
                data: const MediaQueryData(),
                child: MaterialApp(
                    home: Scaffold(
                      body:
                      Container(
                          padding: const EdgeInsets.all(30.0),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                            child: GestureDetector(
                                child: Container(
                                  height: 160,
                                  child: Row(
                                    children: getColorBox(colors),
                                  ),
                                )
                            ),
                          )
                      ),

                    )
                )
            )*/
        Container(
            padding: const EdgeInsets.all(30.0),
            decoration: BoxDecoration(
              border:
              Border.all(color: Colors.blueAccent, width: 5.0),
              color: Colors.redAccent,
            ),
            child: Text("This is an invisible widget"))
        )
        .then((capturedImage) {
//from path_provide package
      String fileName = DateTime.now().microsecondsSinceEpoch.toString();
      var path = '$directory';
      screenshotController.captureAndSave(
          path,
          fileName: fileName
      );


      Share.shareFiles(['${path}/${fileName}'], text: "look at this cool color scheme!");

    });
  }

}