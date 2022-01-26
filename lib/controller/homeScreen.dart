import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:object_detector/main.dart';
import 'package:tflite/tflite.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isWorking = false;
  String result = "";
  CameraController? cameraController;
  CameraImage? cameraImage;

  @override
  Widget build(BuildContext context) {
    if (!cameraController!.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height - 200,
            width: MediaQuery.of(context).size.width,
            child: AspectRatio(
              aspectRatio: cameraController!.value.aspectRatio,
              child: CameraPreview(cameraController!),
            ),
            color: Colors.red,
          ),
          Container(height:100,child: Text(result),)
        ],
      ),
    );
  }

  runStreamData() async {
    if (cameraImage != null) {
      var recognition = await Tflite.runModelOnFrame(
          bytesList: cameraImage!.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          imageHeight: cameraImage!.height,
          imageWidth: cameraImage!.width,
          imageMean: 127.5,
          imageStd: 127.5,
          rotation: 90,
          numResults: 2,
          threshold: 0.1,
          asynch: true);

      result = "";

      recognition?.forEach((element) {
        result += element["label"] +
            "  " +
            (element["confidence"] as double).toStringAsFixed(2) +
            "\n";
      });
      setState(() {
        result;
      });
      isWorking = false;
    }
  }

  @override
  void initState() {
    super.initState();
    loadModel();
    cameraController = CameraController(cameras![0], ResolutionPreset.max);
    cameraController?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        cameraController?.startImageStream((image) => {
              if (!isWorking)
                {
                  isWorking = true,
                  cameraImage = image,
                  runStreamData()
                }
            });
      });
    });
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await Tflite.close();
    cameraController?.dispose();
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/mobilenet_v1_1.0_224.tflite',
        labels: 'assets/mobilenet_v1_1.0_224.txt');
  }
}
