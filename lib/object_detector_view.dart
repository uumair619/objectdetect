import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:objectdetect/utils.dart';

import 'camera_view.dart';
import 'detector_view.dart';
import 'object_detector_painter.dart';

class ObjectDetectorView extends StatefulWidget {
  ObjectDetectorView({
    Key? key,
    required this.type,
  }) : super(key: key);

  final String type;
  @override
  State<ObjectDetectorView> createState() => _ObjectDetectorView();
}

class _ObjectDetectorView extends State<ObjectDetectorView> {
  ObjectDetector? _objectDetector;
  DetectionMode _mode = DetectionMode.stream;
  bool _canProcess = false;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;
  int _option = 0;

  @override
  void dispose() {
    _canProcess = false;
    _objectDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        DetectorView(
          title: 'Object Detector',
          customPaint: _customPaint,
          text: _text,
          onImage: _processImage,
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
          onCameraFeedReady: _initializeDetector,
          initialDetectionMode: DetectorViewMode.values[_mode.index],
          onDetectorViewModeChanged: _onScreenModeChanged,
        ),
        Positioned(
            top: 30,
            left: 100,
            right: 100,
            child: Row(
              children: [
                Spacer(),

                Spacer(),
              ],
            )),
      ]),
    );
  }

  void _onScreenModeChanged(DetectorViewMode mode) {
    switch (mode) {
      case DetectorViewMode.gallery:
        _mode = DetectionMode.single;
        _initializeDetector();
        return;

      case DetectorViewMode.liveFeed:
        _mode = DetectionMode.stream;
        _initializeDetector();
        return;
    }
  }

  void _initializeDetector() async {
    _objectDetector?.close();
    _objectDetector = null;
    print('Set detector in mode: $_mode');
    final modelName = 'landmark';
    final response =
        await FirebaseObjectDetectorModelManager().downloadModel(modelName);
    print('Downloaded: $response');
    final options = FirebaseObjectDetectorOptions(
      mode: DetectionMode.single,
      modelName: modelName,
      classifyObjects: true,
      multipleObjects: true,
      confidenceThreshold: 0.8
    );
    _objectDetector = ObjectDetector(options: options);



    _canProcess = true;
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (_objectDetector == null) return ;
    if (!_canProcess) return ;
    if (_isBusy) return ;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    var isDetected = -1;
    final objects = await _objectDetector!.processImage(inputImage);
   // print('Objects found: ${objects.length}\n\n');
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      if(objects.isNotEmpty)
        {
          for(var item in objects)
            {
              for (final label in item.labels) {
                if (label.confidence > 0.5) { // Use an appropriate confidence threshold
                  print('Detected: ${label.text} with confidence ${label.confidence}');
                  if(label.text == "Mouse")
                    {
                      if(widget.type == "Mouse")
                        {
                          isDetected = 0;
                          List<DetectedObject> itemAsList = [item];
                          final painter = ObjectDetectorPainter(
                            itemAsList,
                            inputImage.metadata!.size,
                            inputImage.metadata!.rotation,
                            _cameraLensDirection,
                          );
                          _customPaint = CustomPaint(painter: painter);

                        }


                    }
                  else if(label.text == "Mobile phone")
                    {
                      if(widget.type == "Mobile phone")
                        {
                          isDetected = 0;
                          List<DetectedObject> itemAsList = [item];
                          final painter = ObjectDetectorPainter(
                            itemAsList,
                            inputImage.metadata!.size,
                            inputImage.metadata!.rotation,
                            _cameraLensDirection,
                          );
                          _customPaint = CustomPaint(painter: painter);

                        }


                    }
                  else if(label.text == "Computer keyboard" )
                    {
                      if(widget.type == "Computer keyboard")
                        {
                          isDetected = 0;
                          List<DetectedObject> itemAsList = [item];
                          final painter = ObjectDetectorPainter(
                            itemAsList,
                            inputImage.metadata!.size,
                            inputImage.metadata!.rotation,
                            _cameraLensDirection,
                          );
                          _customPaint = CustomPaint(painter: painter);

                        }


                    }
                  else if(label.text == "Electronic device" )
                  {
                    if(widget.type == "Electronic device")
                    {
                      isDetected = 0;
                      List<DetectedObject> itemAsList = [item];
                      final painter = ObjectDetectorPainter(
                        itemAsList,
                        inputImage.metadata!.size,
                        inputImage.metadata!.rotation,
                        _cameraLensDirection,
                      );
                      _customPaint = CustomPaint(painter: painter);

                    }


                  }


                }
              }
            }
        }
      if(isDetected == -1)
        {
          _customPaint = null;

        }
    /*  final painter = ObjectDetectorPainter(
        objects,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);*/
    } else {
      String text = 'Objects found: ${objects.length}\n\n';
      for (final object in objects) {
        text +=
            'Object:  trackingId: ${object.trackingId} - ${object.labels.map((e) => e.text)}\n\n';
      }
      _text = text;
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }

  }

 /* Future<void> _takePhoto() async {
    final file = await _cameraController.takePicture();
    print('Photo taken: ${file.path}');
  }*/
}
