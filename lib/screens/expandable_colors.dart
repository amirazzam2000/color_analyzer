import 'dart:ui';
import 'dart:ui' as ui;

import 'package:color_analayzer/Colors/color_data_object.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' as f;
import 'package:googleapis/vision/v1.dart';

class ExpandableColorPallet extends StatefulWidget {
  List<ColorDataObject> colors;

  ExpandableColorPallet({Key? key, required this.colors}) : super(key: key);

  @override
  State<ExpandableColorPallet> createState() => _ExpandableColorPalletState();
}

class _ExpandableColorPalletState extends State<ExpandableColorPallet> {
  bool stateIsExpanded = false;

  List<Widget> getColorBox(List<ColorDataObject> colors) {
    List<Widget> widgets = <Widget>[];
    colors.sort((ColorDataObject a, ColorDataObject b ) => ((b.score * 100) -  (a.score * 100) ).round());
    for (int i = 0; i < colors.length; i++) {
      widgets.add(
          Expanded(
            child: Container(
              color: f.Color.fromRGBO(
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

  List<Widget> getColorList(List<ColorDataObject> colors, context){
    List<Widget> widgets = <Widget>[];
    colors.sort((ColorDataObject a, ColorDataObject b ) => ((b.score * 100) -  (a.score * 100) ).round());
    for(int i = 0; i< colors.length; i++){
      var color = f.Color.fromRGBO(
          colors[i].rgb.red,
          colors[i].rgb.green,
          colors[i].rgb.blue,
          1
      );
      widgets.add(
          Padding(

            padding: const EdgeInsets.all(8.0),
            child:  Container(
              child: GestureDetector(
                onLongPress: (){
                  Clipboard.setData(ClipboardData(text: '#${color.value.toRadixString(16)}'));
                  ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                    content: Text("Copied to Clipboard!"),
                    behavior: SnackBarBehavior.floating,
                  ));

                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.all((Radius.circular(10))),
                  child: ExpansionTile(
                    //trailing: const SizedBox.shrink(),
                    expandedAlignment: const Alignment(0.0, 0.0),
                    title: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            color: color,
                            borderRadius: const BorderRadius.all((Radius.circular(10))
                            )
                        ),
                        child: Center(
                          child: Text(
                            colors[i].name +  " (" + '#${color.value.toRadixString(16)}' + ") ",
                            //color.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              color: color.computeLuminance() <= 0.4 ? Colors.white: Colors.black ,
                            ),
                          ),
                        )
                    ),
                    backgroundColor: color,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0,0,8),
                            child: Text(
                              "RGB value: ("
                                  +colors[i].rgb.red .toString()
                                  + ", " + colors[i].rgb.green.toString()
                                  + ", " + colors[i].rgb.blue.toString() + ")",
                              //color.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: color.computeLuminance() <= 0.4 ? Colors.white: Colors.black ,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0,0,8),
                            child: Text(
                              "HSV value: ("
                                  +colors[i].hsv.hue .toString()
                                  + ", " + colors[i].hsv.saturation.toString() + "%"
                                  + ", " + colors[i].hsv.value.toString() + "% )",
                              //color.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: color.computeLuminance() <= 0.4 ? Colors.white: Colors.black ,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0,0,8),
                            child: Text(
                              "HSL value: ("
                                  +colors[i].hsl.hue .toString()
                                  + ", " + colors[i].hsl.saturation.toString() + "% "
                                  + ", " + colors[i].hsl.luminosity.toString() + "% )",
                              //color.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: color.computeLuminance() <= 0.4 ? Colors.white: Colors.black ,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0,0,8),
                            child: Text(
                              "CMYK value: ("
                                  +colors[i].cmyk.cyan .toString()
                                  + ", " + colors[i].cmyk.magenta.toString()
                                  + ", " + colors[i].cmyk.yellow.toString()
                                  + ", " + colors[i].cmyk.key.toString() + ")",
                              //color.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: color.computeLuminance() <= 0.4 ? Colors.white: Colors.black ,
                              ),
                            ),
                          ),
                        ],
                      )


                    ],
                  ) ,
                ),

              ),



            ),
          )
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: _buildPanel(),
      ),
    );
  }

  Widget _buildPanel() {
    return
      ExpansionTile(
        trailing: const SizedBox.shrink(),
        expandedAlignment: Alignment(0.0, 0.0),
        title: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
          child: GestureDetector(
              child: Container(
                height: 160,
                child: Row(
                  children: getColorBox(widget.colors),
                ),
              )
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              child: Column(
                children: getColorList(widget.colors, context),
              ),
            ),
          ),
        ],
      );
  }


}
