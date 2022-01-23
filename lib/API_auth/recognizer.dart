import 'dart:core';

import 'package:color_analayzer/Colors/color_data_object.dart';
import 'package:color_analayzer/Colors/color_manager.dart';
import 'package:color_analayzer/Data/defaults.dart';
import 'package:flutter/material.dart' as f;
import 'package:googleapis/docs/v1.dart' as v;
import 'package:googleapis/vision/v1.dart';
import 'dart:core' as core;


import 'auth.dart';

class Recognizer {
    final _client = Auth().client;

    core.Future<core.List<ColorDataObject>> search(core.String image) async {
        var _vision = VisionApi(await _client);
        var _api = _vision.images;
        var _response = await _api.annotate(BatchAnnotateImagesRequest.fromJson({
        "requests": [
            {
                "image": {"content": image},
                "features": [
                    {
                        "maxResults": Defaults.getDefaults().numberOfColors.round(),
                        "type": "IMAGE_PROPERTIES"
                    }
                ],
            }
        ]
        }));

        core.print("formating data");



        var _label = _response.responses?.first.imagePropertiesAnnotation?.dominantColors?.colors;

        late core.List<ColorDataObject> colors = <ColorDataObject>[];

        if (_label != null){
            for(int i = 0; i < _label.length; i++){
                ColorDataObject c = await ColorManager.getColorDataObject(
                    _label[i].color!.red!.round(),
                    _label[i].color!.blue!.round(),
                    _label[i].color!.green!.round(),
                    _label[i].score!
                );
               colors.add(c);
            }
        }
        /*
        _response.responses?.forEach((data) {
              var _label = data.imagePropertiesAnnotation?.dominantColors?.colors;
              if (_label != null){
                  _bestGuessLabel = _label as List;
              }

        });
        */

        core.print("got an output");

        return colors;
    }
}