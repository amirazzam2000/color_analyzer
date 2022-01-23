class RGB {
  late int red;
  late int blue;
  late int green;

  RGB(this.red, this.green, this.blue);
}

class HSV {
  late int hue;
  late int saturation;
  late int value;

  HSV(this.hue, this.saturation, this.value);
}

class HSL {
  late int hue;
  late int saturation;
  late int luminosity;

  HSL(this.hue, this.saturation, this.luminosity);
}

class CMYK {
  late int cyan;
  late int magenta;
  late int yellow;
  late int key;

  CMYK(this.cyan, this.magenta, this.yellow, this.key);
}

class ColorDataObject{
  ColorDataObject(
      {required this.hex, required this.rgb, required this.hsv, required this.hsl, required this.cmyk, required this.name}
      );
  late String hex;
  late RGB rgb;
  late HSV hsv;
  late HSL hsl;
  late CMYK cmyk;
  late double score;
  late String name;

  factory ColorDataObject.fromJson(Map<String, dynamic> json) =>
      ColorDataObject(
        hex: json["hex"]["value"],
        rgb: new RGB(json["rgb"]["r"], json["rgb"]["g"], json["rgb"]["b"]),
        hsv: new HSV(json["hsv"]["h"], json["hsv"]["s"], json["hsv"]["v"]),
        cmyk: new CMYK(json["cmyk"]["c"]?? 0, json["cmyk"]["m"]?? 0, json["cmyk"]["y"]?? 0, json["cmyk"]["k"]?? 0),
        name: json["name"]["value"],
        hsl: new HSL(json["hsl"]["h"], json["hsl"]["s"], json["hsl"]["l"]),
      );

}