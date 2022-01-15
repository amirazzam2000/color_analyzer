import 'dart:ui';
import 'dart:ui' as ui;

import 'package:color_analayzer/Colors/color_data_object.dart';
import 'package:color_analayzer/Colors/color_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' as f;
import 'package:googleapis/vision/v1.dart';

import 'expandable_colors.dart';

class ExpandableColorScheme extends StatefulWidget {
  ColorDataObject color;
  String schemeName;

  ExpandableColorScheme({Key? key, required this.color, required this.schemeName}) : super(key: key);

  @override
  State<ExpandableColorScheme> createState() => _ExpandableColorSchemeState();
}

class _ExpandableColorSchemeState extends State<ExpandableColorScheme> {
  bool stateIsExpanded = false;

  Future<List<ColorDataObject>> getColorScheme() async{
    print("requesting info");


    List<ColorDataObject> label = await ColorManager.getColorScheme(
        widget.color.rgb.red,
        widget.color.rgb.green,
        widget.color.rgb.blue,
        widget.schemeName
    );

    return label;
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
        expandedAlignment: Alignment(0.0, 0.0),
        title: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
          child: Text(
          widget.schemeName,
          style: const TextStyle(
          color: Colors.black,
            fontSize: 20,
            //fontWeight: FontWeight.bold,
          ),
          )
        ),
        children: [
          FutureBuilder<List<ColorDataObject>>(
              future: getColorScheme(),
              //initialData: 'Color_Name',
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      child: Column(
                        children: [
                          ExpandableColorPallet(
                            colors: snapshot.data!,
                          ),
                        ]
                      ),
                    ),
                  );
                }else{
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }
            )

        ],
      );
  }


}
