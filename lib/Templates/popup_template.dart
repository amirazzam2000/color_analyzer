import 'package:flutter/material.dart';
import 'package:flutter_beautiful_popup/main.dart';

class PopUpTemplate extends BeautifulPopupTemplate {
  final BeautifulPopup options;
  PopUpTemplate(this.options) : super(options);

  @override
  Color get primaryColor => Colors.deepPurpleAccent; // The default primary color of the template is Colors.black.
  @override
  final maxWidth = 400; // In most situations, the value is the illustration size.
  @override
  final maxHeight = 600;
  @override
  final bodyMargin = 10;

  // You need to adjust the layout to fit into your illustration.
  @override
  get layout {
    return [
      Positioned(
        child: Container(
          color: Colors.white,
        ),
      ),
      Positioned(
        top: percentH(10),
        child: title,
      ),
      Positioned(
        top: percentH(20),
        height: percentH(actions == null ? 52 : 62),
        left: percentW(10),
        right: percentW(10),
        child: content,
      ),
      Positioned(
        bottom: percentW(10),
        left: percentW(10),
        right: percentW(10),
        child: actions ?? Container(),
      ),
    ];
  }
}