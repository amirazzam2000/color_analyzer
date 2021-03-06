import 'dart:io';

import 'package:camera/camera.dart';
import 'package:color_analayzer/Data/defaults.dart';
import 'package:color_analayzer/screens/captures_screen.dart';
import 'package:color_analayzer/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:color_analayzer/screens/preview_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../main.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? controller;
  VideoPlayerController? videoController;

  File? _imageFile;
  File? _videoFile;

  // Initial values
  bool _isCameraInitialized = false;
  bool _isRearCameraSelected = true;
  bool _isVideoCameraSelected = false;
  bool _isRecordingInProgress = false;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;


  // Current values
  double _currentZoomLevel = 1.0;
  double _currentExposureOffset = 0.0;
  FlashMode? _currentFlashMode;

  List<File> allFileList = [];

  final resolutionPresets = ResolutionPreset.values;

  ResolutionPreset currentResolutionPreset = ResolutionPreset.ultraHigh;

  refreshAlreadyCapturedImages() async {
    final directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> fileList = await directory.list().toList();
    allFileList.clear();
    List<Map<int, dynamic>> fileNames = [];

    fileList.forEach((file) {
      if (file.path.contains('.jpg') || file.path.contains('.mp4')) {
        allFileList.add(File(file.path));

        String name = file.path.split('/').last.split('.').first;
        fileNames.add({0: int.parse(name), 1: file.path.split('/').last});
      }
    });

    if (fileNames.isNotEmpty) {
      final recentFile =
      fileNames.reduce((curr, next) => curr[0] > next[0] ? curr : next);
      String recentFileName = recentFile[1];
      if (recentFileName.contains('.mp4')) {
        _videoFile = File('${directory.path}/$recentFileName');
        _imageFile = null;
        _startVideoPlayer();
      } else {
        _imageFile = File('${directory.path}/$recentFileName');
        _videoFile = null;
      }

      setState(() {});
    }
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

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (controller!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }

    try {
      await cameraController!.startVideoRecording();
      setState(() {
        _isRecordingInProgress = true;
        print(_isRecordingInProgress);
      });
    } on CameraException catch (e) {
      print('Error starting to record video: $e');
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }

    try {
      XFile file = await controller!.stopVideoRecording();
      setState(() {
        _isRecordingInProgress = false;
      });
      return file;
    } on CameraException catch (e) {
      print('Error stopping video recording: $e');
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Video recording is not in progress
      return;
    }

    try {
      await controller!.pauseVideoRecording();
    } on CameraException catch (e) {
      print('Error pausing video recording: $e');
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }

    try {
      await controller!.resumeVideoRecording();
    } on CameraException catch (e) {
      print('Error resuming video recording: $e');
    }
  }

  void resetCameraValues() async {
    _currentZoomLevel = 1.0;
    _currentExposureOffset = 0.0;
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    resetCameraValues();

    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);

      _currentFlashMode = controller!.value.flashMode;
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  @override
  void initState() {
    // Hide the status bar in Android
    SystemChrome.setEnabledSystemUIOverlays([]);
    // Set and initialize the new camera
    onNewCameraSelected(cameras[0]);
    refreshAlreadyCapturedImages();
    Defaults.getDefaults();
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
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _isCameraInitialized
            ? Stack(
          children: [

            Column(
              children: [
                AspectRatio(
                  aspectRatio: mediaSize.aspectRatio, // 1 /controller!.value.aspectRatio,
                  child: Stack(
                    children: [
                      controller!.buildPreview(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          8.0,
                          16.0,
                          8.0,
                          0.0,
                        ),
                        child:
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  0.0,
                                  8.0,
                                  0.0,
                                  0.0
                              ),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius:
                                  BorderRadius.only(
                                      topRight: Radius.circular(10.0),
                                      bottomRight: Radius.circular(0.0),
                                      topLeft: Radius.circular(10.0),
                                      bottomLeft: Radius.circular(0.0)
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
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
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black87,
                                              borderRadius:
                                              BorderRadius.circular(10.0),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                _currentZoomLevel.toStringAsFixed(1) +
                                                    'x',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          onTap: _isRecordingInProgress
                                              ? () async {
                                            if (controller!
                                                .value.isRecordingPaused) {
                                              await resumeVideoRecording();
                                            } else {
                                              await pauseVideoRecording();
                                            }
                                          }
                                              : () {
                                            setState(() {
                                              _isCameraInitialized = false;
                                            });
                                            onNewCameraSelected(cameras[
                                            _isRearCameraSelected ? 1 : 0]);
                                            setState(() {
                                              _isRearCameraSelected =
                                              !_isRearCameraSelected;
                                            });
                                          },
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              const Icon(
                                                Icons.circle,
                                                color: Colors.black38,
                                                size: 60,
                                              ),
                                              _isRecordingInProgress
                                                  ? controller!
                                                  .value.isRecordingPaused
                                                  ? const Icon(
                                                Icons.play_arrow,
                                                color: Colors.white,
                                                size: 30,
                                              )
                                                  : const Icon(
                                                Icons.pause,
                                                color: Colors.white,
                                                size: 30,
                                              )
                                                  : Icon(
                                                _isRearCameraSelected
                                                    ? Icons.camera_front
                                                    : Icons.camera_rear,
                                                color: Colors.deepPurpleAccent,
                                                size: 30,
                                              ),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: _isVideoCameraSelected
                                              ? () async {
                                            if (_isRecordingInProgress) {
                                              XFile? rawVideo =
                                              await stopVideoRecording();
                                              File videoFile =
                                              File(rawVideo!.path);

                                              int currentUnix = DateTime.now()
                                                  .millisecondsSinceEpoch;

                                              final directory =
                                              await getApplicationDocumentsDirectory();

                                              String fileFormat = videoFile.path
                                                  .split('.')
                                                  .last;

                                              _videoFile = await videoFile.copy(
                                                '${directory.path}/$currentUnix.$fileFormat',
                                              );

                                              _startVideoPlayer();
                                            } else {
                                              await startVideoRecording();
                                            }
                                          }
                                              : () async {
                                            XFile? rawImage =
                                            await takePicture();
                                            File imageFile =
                                            File(rawImage!.path);

                                            int currentUnix = DateTime.now()
                                                .millisecondsSinceEpoch;

                                            final directory =
                                            await getApplicationDocumentsDirectory();

                                            String fileFormat =
                                                imageFile.path.split('.').last;

                                            print(fileFormat);

                                            await imageFile.copy(
                                              '${directory.path}/$currentUnix.$fileFormat',
                                            );

                                            refreshAlreadyCapturedImages();

                                            Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                builder: (context) => PreviewScreen(
                                                  fileList: allFileList,
                                                  imageFile: imageFile,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Icon(
                                                Icons.circle,
                                                color: _isVideoCameraSelected
                                                    ? Colors.deepPurpleAccent
                                                    : Colors.deepPurpleAccent,
                                                size: 80,
                                              ),
                                              Icon(
                                                Icons.circle,
                                                color: _isVideoCameraSelected
                                                    ? Colors.red
                                                    : Colors.white54,
                                                size: 65,
                                              ),
                                              _isVideoCameraSelected &&
                                                  _isRecordingInProgress
                                                  ? const Icon(
                                                Icons.stop_rounded,
                                                color: Colors.white,
                                                size: 32,
                                              )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0.0,
                                              0.0,
                                              16.0,
                                              0.0
                                          ),
                                          child: InkWell(
                                            onTap:
                                            _imageFile != null || _videoFile != null
                                                ? () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CapturesScreen(
                                                        imageFileList: allFileList,
                                                      ),
                                                ),
                                              );
                                            }
                                                : null,
                                            child: Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                BorderRadius.circular(10.0),
                                                border: Border.all(
                                                  color: Colors.deepPurple,
                                                  width: 2,
                                                ),
                                                image: _imageFile != null
                                                    ? DecorationImage(
                                                  image: FileImage(_imageFile!),
                                                  fit: BoxFit.cover,
                                                )
                                                    : null,
                                              ),
                                              child: videoController != null &&
                                                  videoController!
                                                      .value.isInitialized
                                                  ? ClipRRect(
                                                borderRadius:
                                                BorderRadius.circular(8.0),
                                                child: AspectRatio(
                                                  aspectRatio: videoController!
                                                      .value.aspectRatio,
                                                  child: VideoPlayer(
                                                      videoController!),
                                                ),
                                              )
                                                  : Container(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )

                          ],
                        ),


                      ),
                    ],
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) =>  SettingsScreen(),
                  ),
                );
              },
              child: Icon(Icons.settings, size: 30),
              style: TextButton.styleFrom(
                  primary: Colors.deepPurple,
                  //backgroundColor: Colors.,
                  textStyle: const TextStyle(fontSize: 20)
              ),
            ),
          ]
        ) : const Center(
          child: Text(
            'LOADING',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
