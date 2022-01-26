ObjectDetector(Flutter):

Description:
    1. Get image from stream using mobile camera.
    2. After get the image, try to detect the object in the image using ML.
    3. If image contain any object, it doesnot return any value.

Used Plugins:
    1. camera
    2. tflite
    3. splashscreen

Integration:
    Note: ObjectDetector detect the object from the image with the help of TFlite plugin.

    1. Add camera and tflite in pubspec.yaml file
    2. In this project I have added trained tflite and txt file in assets folder and included that files in pubspec.yaml also.
    3. In home screen default opens back camera view and continuously stream the data from camera.
    4. Using camera plugin we will get the stream of camera image data.
    5. Once we receive image stream from camera, that image hs passed to tflite and try to detect the object which is placed in the image.
    6. using runStreamData method to detect the object from image

    7. runStreamData() async {
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

  8. In the runStreamData method, used to convert normal image stream to bytes.
  9. Using Tflite.runModelOnFrame, get object from the image with the help of trained data tflite file.
  10. Finally we get the object name from the image, its shows in textview in the bottom of the screen.



-------In Project folder I have attached the app screenshots, please refer that one...______________