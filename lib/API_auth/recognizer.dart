import 'package:googleapis/vision/v1.dart';

import 'auth.dart';

class Recognizer {
    final _client = Auth().client;

    Future<WebLabel?> search(String image) async {
        var _vision = VisionApi(await _client);
        var _api = _vision.images;
        var _response = await _api.annotate(BatchAnnotateImagesRequest.fromJson({
        "requests": [
            {
                "image": {"content": image},
                "features":
                    [
                        {"type": "WEB_DETECTION"}
                    ]
            }
        ]
        }));

        WebLabel? _bestGuessLabel;
        _response.responses?.forEach((data) {
              var _label = data.webDetection?.bestGuessLabels;
              _bestGuessLabel = _label?.single;
        });

        print("here is the output");
        print( _bestGuessLabel?.label);

        return _bestGuessLabel;
    }
}