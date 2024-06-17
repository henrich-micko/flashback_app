import 'package:camera/camera.dart';

Future<CameraDescription> getCamera() async {
  final cameras = await availableCameras();
  return cameras.first;
}

Future<CameraController> getCameraController() async {
  final camera = await getCamera();
  return CameraController(camera, ResolutionPreset.medium);
}