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
import 'package:color_analayzer/Templates/popup_template.dart';
import 'package:color_analayzer/screens/camera_screen.dart';
import 'package:color_analayzer/screens/scheme_loader.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:color_analayzer/screens/captures_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beautiful_popup/main.dart';
import 'package:googleapis/vision/v1.dart';
import 'package:flutter/src/widgets/image.dart' as img;
import 'package:flutter/material.dart' as f;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io' as Io;

import 'expandable_colors.dart';




class PreviewScreen extends StatefulWidget {
  final File imageFile;
  final List<File> fileList;

  PreviewScreen({
    required this.imageFile,
    required this.fileList,
  });

  @override
  State<StatefulWidget> createState() => _PreviewState();
}

class _PreviewState extends State<PreviewScreen>
{
  var chosenColor;

  Future<Map<String, dynamic>> getColorName() async{
    print("requesting info");

    final bytes = await widget.imageFile.readAsBytes();
    List<ColorDataObject> label = (await Recognizer().search(base64Encode(bytes)));
    label.sort((ColorDataObject a, ColorDataObject b ) => ((b.score * 100) -  (a.score * 100) ).round());

    var color = label[0];
    if (chosenColor == null){
      Defaults.getDefaults().color = color;
      chosenColor = color;
    }



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
                      child: img.Image.file(widget.imageFile),
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
                          decoration: const BoxDecoration(
                              //color: ui.Color(0xFFCAA7FD),
                              color: Colors.white,
                              /*ui.Color.fromRGBO(
                                  snapshot.data!["DominantColor"].rgb.red  - 80 ,
                                  snapshot.data!["DominantColor"].rgb.green - 80,
                                  snapshot.data!["DominantColor"].rgb.blue  - 80,
                                  1
                              ),*/
                              borderRadius: BorderRadius.vertical(top: (Radius.circular(20))
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

                                  Padding(
                                    padding: const EdgeInsets.fromLTRB( 0, 30, 0, 0,),
                                    child:
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center ,
                                          children: [

                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: TextButton(

                                                onPressed: () {
                                                  final popup = BeautifulPopup.customize(
                                                    context: context,
                                                    build: (options) =>
                                                        PopUpTemplate(

                                                        options,

                                                    ),
                                                  );
                                                  popup.show(
                                                    title: 'Pick Color: ',
                                                    content: Container(
                                                      color: Colors.white,
                                                      child: Scrollbar(
                                                        isAlwaysShown: true,
                                                        child: ListView.builder(
                                                            itemCount: snapshot.data!["DominantColorList"].length,
                                                            itemBuilder: (BuildContext context, int index) {
                                                              return Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Container(
                                                                    height: 50,
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(20),
                                                                      color: ui.Color.fromRGBO(
                                                                          snapshot.data!["DominantColorList"][index].rgb.red   ,
                                                                          snapshot.data!["DominantColorList"][index].rgb.green ,
                                                                          snapshot.data!["DominantColorList"][index].rgb.blue  ,
                                                                          1
                                                                      ),
                                                                    ),
                                                                    child: Center(
                                                                      child: TextButton(
                                                                          onPressed: () {
                                                                            print("pressed " + snapshot.data!["DominantColorList"][index].name);
                                                                            Defaults.getDefaults().color = snapshot.data!["DominantColorList"][index];
                                                                            Navigator.pop(context);
                                                                            setState(() {
                                                                              chosenColor = Defaults.getDefaults().color;
                                                                            });
                                                                          },
                                                                          child: Text(
                                                                              snapshot.data!["DominantColorList"][index].name,
                                                                              style: TextStyle(
                                                                                color: snapshot.data!["DominantColorList"][index].hsl.luminosity > 40? Colors.black: Colors.white,
                                                                                ),
                                                                          ),
                                                                      ),
                                                                    )),
                                                              );
                                                            }),
                                                      ),
                                                    ),
                                                    actions: [
                                                      popup.button(
                                                        label: 'Close',
                                                        onPressed: Navigator.of(context).pop,
                                                      ),
                                                    ],
                                                  );

                                                },
                                                child: Container(
                                                  height: 30,
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                    color: ui.Color.fromRGBO(
                                                        chosenColor.rgb.red,
                                                        chosenColor.rgb.green,
                                                        chosenColor.rgb.blue,
                                                        1
                                                    ),
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const Text(
                                              "Color Schemes: ",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),

                                  ),

                                  ExpandableColorScheme(
                                    schemeName: 'monochrome',
                                    color: chosenColor,

                                  ),

                                  ExpandableColorScheme(
                                    schemeName: 'monochrome-dark',
                                    color: chosenColor,

                                  ),

                                  ExpandableColorScheme(
                                    schemeName: 'monochrome-light',
                                    color: chosenColor,

                                  ),

                                  ExpandableColorScheme(
                                    schemeName: 'analogic',
                                    color: chosenColor,

                                  ),

                                  ExpandableColorScheme(
                                    schemeName: 'complement',
                                    color: chosenColor,

                                  ),

                                  ExpandableColorScheme(
                                    schemeName: 'analogic-complement',
                                    color: chosenColor,

                                  ),

                                  ExpandableColorScheme(
                                    schemeName: 'triad',
                                    color: chosenColor,

                                  ),

                                  ExpandableColorScheme(
                                    schemeName: 'quad',
                                    color: chosenColor,

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