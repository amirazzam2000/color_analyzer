import 'dart:convert';

import 'package:color_analayzer/Colors/color_data_object.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Defaults{
  late ColorDataObject color;
  double numberOfColors = 10.0;
  static Defaults? _defaults;
  bool monochromeScheme = true;
  bool monochromeDarkScheme = true;
  bool monochromeLightScheme = true;
  bool analogicScheme = true;
  bool complementScheme = true;
  bool analogicComplementScheme = true;
  bool triadScheme = true;
  bool quadScheme = true;

  Defaults();

  static void load() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('content');

    _defaults = Defaults();

    if (jsonString != null) {
      _defaults = Defaults.fromJson(json.decode(jsonString));
    }
  }

  static Defaults getDefaults(){
    if(_defaults == null) {
      print("loading data .... ");
      _defaults = Defaults();
      load();
    }
    return _defaults!;
  }

  bool isSchemeChecked(String scheme){
    switch (scheme){
      case "monochrome":
        return getDefaults().monochromeScheme;
      case "monochrome-dark":
        return getDefaults().monochromeDarkScheme;
      case "monochrome-light":
        return getDefaults().monochromeLightScheme;
      case "analogic":
        return getDefaults().analogicScheme;
      case "complement":
        return getDefaults().complementScheme;
      case "analogic-complement":
        return getDefaults().analogicComplementScheme;
      case "triad":
        return getDefaults().triadScheme;
      case "quad":
        return getDefaults().quadScheme;
    }
    return false;
  }

  Defaults.fromJson(Map<String, dynamic> json)
      : monochromeScheme = json['monochromeScheme'],
        monochromeDarkScheme = json['monochromeDarkScheme'],
        monochromeLightScheme = json['monochromeLightScheme'],
        analogicScheme = json['analogicScheme'],
        complementScheme = json['complementScheme'],
        analogicComplementScheme = json['analogicComplementScheme'],
        triadScheme = json['triadScheme'],
        quadScheme = json['quadScheme'],
        numberOfColors = json['numberOfColors'];

  Map<String, dynamic> toJson() => {
    'monochromeScheme':   monochromeScheme,
    'monochromeDarkScheme':   monochromeDarkScheme,
    'monochromeLightScheme':   monochromeLightScheme,
    'analogicScheme':   analogicScheme,
    'complementScheme':   complementScheme,
    'analogicComplementScheme':   analogicComplementScheme,
    'triadScheme':   triadScheme,
    'quadScheme':   quadScheme,
    'numberOfColors':  numberOfColors,
  };

  void reset() {
    _defaults = null;
  }
}