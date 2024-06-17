import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api_client.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class CreateFlashbackScreen extends StatefulWidget {
  final int eventId;

  const CreateFlashbackScreen({super.key, required this.eventId});

  @override
  State<CreateFlashbackScreen> createState() => _CreateFlashbackScreenState();
}

class _CreateFlashbackScreenState extends State<CreateFlashbackScreen> {
  late Future<List<CameraDescription>> _futureCameras;
  late Future<ApiClient> _apiClient;
  late Future<Event> _futureEvent;
  late Future<CameraController> _futureCameraController;
  late Future<void> _futureCameraInit;
  int _currentCamera = 0;
  File? _flashbackPreview;
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiModel.fromContext(context).api;
    _futureCameras = availableCameras();
    _setupCameras();
    _futureEvent = _apiClient.then((api) => api.event.get(widget.eventId));
  }

  void _setupCameras() {
    final futureCamera = _futureCameras.then((cameras) => cameras[_currentCamera]);
    _futureCameraController = futureCamera.then((camera) => CameraController(camera, ResolutionPreset.veryHigh));
    _futureCameraInit = _futureCameraController.then((controller) => controller.initialize());
  }

  void _takePicture() async {
      await _futureCameraInit;
      final image = await _futureCameraController.then((camera) => camera.takePicture());
      if (!context.mounted) return;
      setState(() {
        _flashbackPreview = File(image.path);
      });
  }

  void _switchCamera() {
    setState(() {
      _currentCamera = _currentCamera == 0 ? 1 : 0;
    });

    final futureCamera = _futureCameras.then((cameras) => cameras[_currentCamera]);
    futureCamera.then((camera) =>
        _futureCameraController.then((controller) => controller.setDescription(camera))
    );
  }

  void _switchFlashMode() {
    setState(() {
      _flashMode = _flashMode == FlashMode.off ? FlashMode.auto :
                   _flashMode == FlashMode.auto ? FlashMode.always : FlashMode.off;
    });

    _futureCameraController.then((controller) => controller.setFlashMode(_flashMode));
  }

  void _handlePost() {
    if (_flashbackPreview == null) return;
    _apiClient.then((api) =>
      api.event.flashback.create(widget.eventId, _flashbackPreview!)
    );
    context.go("/home");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: getFutureBuilder(_futureEvent, (event) => Text("${event.emoji.code} ${event.title}", style: const TextStyle(fontSize: 32))),
        leading: IconButton(
            icon: const Icon(Symbols.arrow_back),
            onPressed: () => _flashbackPreview == null ? context.go("/home") : setState(() {
              _flashbackPreview = null;
            }),
        ),
        actions: [
          IconButton(onPressed: () => context.go("/event/${widget.eventId}"), icon: const Icon(Icons.more_vert))
        ],
      ),
      body: FutureBuilder(
          future: _futureCameraInit,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) return _buildCamera();
            else return _buildLoadingScreen();
          },
      ),
    );
  }

  Widget _buildCamera() {
    Size size = MediaQuery.of(context).size;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: FutureBuilder(future: _futureCameraController, builder: (context, snapshot) {
              if (_flashbackPreview != null)
                return ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: SizedBox(
                        height: size.height - 200,
                        width: _flashbackPreview == null ? size.width : null,
                        child: Image.file(_flashbackPreview!)
                    )
                );

              if (snapshot.hasData)
                return ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    child: SizedBox(
                        height: size.height - 200,
                        width: _flashbackPreview == null ? size.width : null,
                        child: CameraPreview(snapshot.data!)
                    )
                );
              return Container();
            },
          )
        ),

        Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _flashbackPreview == null ? [
              IconButton(
                onPressed: _switchFlashMode,
                iconSize: 25,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                    _flashMode == FlashMode.off ? Symbols.flash_off :
                    _flashMode == FlashMode.auto ? Symbols.flash_auto : Symbols.flash_on,
                    color: Colors.white
                ),
              ),
              const Gap(10),
              IconButton(
                onPressed: _takePicture,
                iconSize: 70,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Symbols.circle, color: Colors.white),
              ),
              const Gap(10),
              IconButton(
                onPressed: _switchCamera,
                iconSize: 25,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Symbols.switch_camera_rounded, color: Colors.white),
              ),
            ] : [
              TextButton(
                onPressed: _handlePost,
                child: const Text("Publish", style: TextStyle(fontSize: 25))
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return const LinearProgressIndicator();
  }
}