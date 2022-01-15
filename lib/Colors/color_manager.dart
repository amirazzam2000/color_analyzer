import 'dart:convert';

import 'package:color_analayzer/Colors/color_data_object.dart';
import 'package:http/http.dart';

class ColorManager{
  static const String IdURL = "https://www.thecolorapi.com/id?";
  static const String SchemeURL = "https://www.thecolorapi.com/scheme?";

  static Future<ColorDataObject> getColorDataObject(int r, int b, int g, double score) async {
    var url = IdURL + "rgb=rgb(" + r.toString() + "," + g.toString() + "," + b.toString() + ")";
    Response res = await get(Uri.parse(url));

    Map<String, dynamic> body = jsonDecode(res.body);

    ColorDataObject color = ColorDataObject.fromJson(body);

    color.score = score;

    return color;

  }

  static Future<List<ColorDataObject>> getColorScheme(int r, int g, int b, String schemeName) async {
    print("getting color scheme");
    var count = 10;
    var url = SchemeURL + "rgb=rgb("
        + r.toString() + ","
        + g.toString() + ","
        + b.toString()
        + ")"+
        "&count="+ count.toString() +
        "&mode=" + schemeName;

    Response res = await get(Uri.parse(url));

    Map<String, dynamic> body = jsonDecode(res.body);
    List<ColorDataObject> colors = <ColorDataObject>[];
    ColorDataObject color;

    for(int i = 0; i < count; i++){
      color = ColorDataObject.fromJson(body["colors"][i]);
      color.score = 1/count;

      colors.add(color);
    }

    print("done getting color scheme!");
    return colors;

  }
}