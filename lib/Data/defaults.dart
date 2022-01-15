import 'package:color_analayzer/Colors/color_data_object.dart';

class Defaults{
  late ColorDataObject color;
  static late Defaults? _defaults;

  Defaults();

  static Defaults getDefaults(){
    _defaults ??= Defaults();
    return _defaults!;
  }
}