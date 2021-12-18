import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../main.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}



class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {

  final resolutionPresets = ResolutionPreset.values;
  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;
  CameraController? controller;
  bool _isCameraInitialized = false;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoomLevel = 1.0;
  File? _imageFile;
  File? _videoFile;
  // To store the retrieved files
  VideoPlayerController? videoController;
  List<File> allFileList = [];

  refreshAlreadyCapturedImages() async {
    // Get the directory
    final directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> fileList = await directory.list().toList();
    allFileList.clear();

    List<Map<int, dynamic>> fileNames = [];

    // Searching for all the image and video files using
    // their default format, and storing them
    fileList.forEach((file) {
      if (file.path.contains('.jpg') || file.path.contains('.mp4')) {
        allFileList.add(File(file.path));

        String name = file.path.split('/').last.split('.').first;
        fileNames.add({0: int.parse(name), 1: file.path.split('/').last});
      }
    });

    // Retrieving the recent file
    if (fileNames.isNotEmpty) {
      final recentFile =
      fileNames.reduce((curr, next) => curr[0] > next[0] ? curr : next);
      String recentFileName = recentFile[1];
      // Checking whether it is an image or a video file
      if (recentFileName.contains('.mp4')) {
        _videoFile = File('${directory.path}/$recentFileName');
      } else {
        _imageFile = File('${directory.path}/$recentFileName');
      }

      setState(() {});
    }
  }

  Future<void> _startVideoPlayer() async {
    if (_videoFile != null) {
      videoController = VideoPlayerController.file(_videoFile!);
      await videoController!.initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized,
        // even before the play button has been pressed.
        setState(() {});
      });
      await videoController!.setLooping(true);
      await videoController!.play();
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );


    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }

    cameraController
        .getMaxZoomLevel()
        .then((value) => _maxAvailableZoom = value);

    cameraController
        .getMinZoomLevel()
        .then((value) => _minAvailableZoom = value);
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
      return null;
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // Hide the status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    onNewCameraSelected(cameras[0]);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? AspectRatio(
        aspectRatio: 1 / controller!.value.aspectRatio,
        child: Stack(
          children: [
            controller!.buildPreview(),
            Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children : [
                  Padding(
                  padding: const EdgeInsets.fromLTRB(8.0,8.0,8.0,0),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                      padding: const EdgeInsets.fromLTRB(3.0,0,3.0,0),
                                      child:  Row(
                                        children: [
                                          Expanded(

                                            child: Slider(
                                              value: _currentZoomLevel,
                                              min: _minAvailableZoom,
                                              max: _maxAvailableZoom,
                                              activeColor: Colors.deepPurpleAccent,
                                              inactiveColor: Colors.white30,
                                              onChanged: (value) async {
                                                setState(() {
                                                  _currentZoomLevel = value;
                                                });
                                                await controller!.setZoomLevel(value);
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(0,0,5.0,0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black87,
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: Text(
                                                  _currentZoomLevel.toStringAsFixed(1) +
                                                      'x',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          )

                                        ],
                                      )
                                  ),

                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Row (
                                children: [
                                  InkWell(

                                    onTap: () async {
                                      XFile? rawImage = await takePicture();
                                      File imageFile = File(rawImage!.path);

                                      int currentUnix = DateTime.now().millisecondsSinceEpoch;
                                      final directory = await getApplicationDocumentsDirectory();
                                      String fileFormat = imageFile.path.split('.').last;

                                      await imageFile.copy(
                                        '${directory.path}/$currentUnix.$fileFormat',
                                      );
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: const [
                                        Icon(Icons.circle, color: Colors.deepPurpleAccent, size: 80),
                                        Icon(Icons.circle, color: Colors.white54, size: 65),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(color: Colors.white, width: 2),
                                      image: _imageFile != null
                                          ? DecorationImage(
                                        image: FileImage(_imageFile!),
                                        fit: BoxFit.cover,
                                      )
                                          : null,
                                    ),
                                    child: videoController != null && videoController!.value.isInitialized
                                        ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: AspectRatio(
                                        aspectRatio: videoController!.value.aspectRatio,
                                        child: VideoPlayer(videoController!),
                                      ),
                                    )
                                        : Container(),
                                  )
                                ],
                              )

                            ),
                          ],
                        )
                    )
                  )
                ]
            ),

          ],
        )

      )
          : Container(),

    );
  }
}

