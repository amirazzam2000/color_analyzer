import 'dart:convert';
import 'dart:core';
import 'dart:core' as core;
import 'package:color_analayzer/Data/defaults.dart';
import 'package:color_analayzer/screens/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState()  => _SettingsState();

}

class _SettingsState extends State<SettingsScreen>
{
  @override
  Widget build(BuildContext context) {
    Defaults.getDefaults();
    return Scaffold (
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();

                        prefs.setString('content', jsonEncode(Defaults.getDefaults()));
                        print("saving data: " + jsonEncode(Defaults.getDefaults()));



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

                  ]
              )
          ),
          Container(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Maximum number of colors: ",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,

                        ),
                      ),
                      Slider(
                        min: 1,
                        max: 10,
                        value: Defaults.getDefaults().numberOfColors,
                        divisions: 9,

                        activeColor: Colors.deepPurpleAccent,
                        inactiveColor: Colors.deepPurpleAccent.shade100,
                        thumbColor: Colors.deepPurple,

                        label: '${Defaults.getDefaults().numberOfColors.round()}',
                        onChanged: (value) {
                          setState(() {
                            Defaults.getDefaults().numberOfColors = value;
                          });

                          }
                        ),
                      const Divider(
                        height: 20,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                        color: Colors.white30,
                      ),
                      const Text(
                        "Select color schemes: ",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,

                        ),
                      ),
                      CheckboxListTile(
                        title: const Text(
                            'Monochrome',
                            style: TextStyle(
                              color: Colors.white
                            ),
                        ),
                        onChanged: (bool? value) {
                          setState(() {
                            Defaults.getDefaults().monochromeScheme =
                                !Defaults.getDefaults().monochromeScheme;
                          });
                        },
                        activeColor: Colors.deepPurpleAccent,

                        value: Defaults.getDefaults().monochromeScheme,
                      ),
                      CheckboxListTile(
                        title: const Text(
                          'Monochrome-dark',
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                        onChanged: (bool? value) {
                          setState(() {
                            Defaults.getDefaults().monochromeDarkScheme =
                            !Defaults.getDefaults().monochromeDarkScheme;
                          });
                        },
                        activeColor: Colors.deepPurpleAccent,

                        value: Defaults.getDefaults().monochromeDarkScheme,
                      ),
                      CheckboxListTile(
                        title: const Text(
                          'Monochrome-light',
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                        onChanged: (bool? value) {
                          setState(() {
                            Defaults.getDefaults().monochromeLightScheme =
                            !Defaults.getDefaults().monochromeLightScheme;
                          });
                        },
                        activeColor: Colors.deepPurpleAccent,

                        value: Defaults.getDefaults().monochromeLightScheme,
                      ),
                      CheckboxListTile(
                        title: const Text(
                          'Analogic',
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                        onChanged: (bool? value) {
                          setState(() {
                            Defaults.getDefaults().analogicScheme =
                            !Defaults.getDefaults().analogicScheme;
                          });
                        },
                        activeColor: Colors.deepPurpleAccent,

                        value: Defaults.getDefaults().analogicScheme,
                      ),
                      CheckboxListTile(
                        title: const Text(
                          'Complement',
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                        onChanged: (bool? value) {
                          setState(() {
                            Defaults.getDefaults().complementScheme =
                            !Defaults.getDefaults().complementScheme;
                          });
                        },
                        activeColor: Colors.deepPurpleAccent,

                        value: Defaults.getDefaults().complementScheme,
                      ),
                      CheckboxListTile(
                        title: const Text(
                          'Analogic-Complement',
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                        onChanged: (bool? value) {
                          setState(() {
                            Defaults.getDefaults().analogicComplementScheme =
                            !Defaults.getDefaults().analogicComplementScheme;
                          });
                        },
                        activeColor: Colors.deepPurpleAccent,

                        value: Defaults.getDefaults().analogicComplementScheme,
                      ),
                      CheckboxListTile(
                        title: const Text(
                          'Triad',
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                        onChanged: (bool? value) {
                          setState(() {
                            Defaults.getDefaults().triadScheme =
                            !Defaults.getDefaults().triadScheme;
                          });
                        },
                        activeColor: Colors.deepPurpleAccent,

                        value: Defaults.getDefaults().triadScheme,
                      ),
                      CheckboxListTile(
                        title: const Text(
                          'Quad',
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                        onChanged: (bool? value) {
                          setState(() {
                            Defaults.getDefaults().quadScheme =
                            !Defaults.getDefaults().quadScheme;
                          });
                        },
                        activeColor: Colors.deepPurpleAccent,

                        value: Defaults.getDefaults().quadScheme,
                      ),
                    ],
                  )
              )


          )
        ],
      ),
    ) ;


  }



}