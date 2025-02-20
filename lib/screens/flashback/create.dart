import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api/event.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flutter/material.dart';
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
  late Future<List<CameraDescription>> _cameras;
  late EventApiDetailClient _eventApiClient;
  late Future<Event> _event;
  late Future<CameraController> _cameraController;
  late Future<void> _cameraInit;
  int _currentCamera = 1;
  File? _flashbackPreview;
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();

    _eventApiClient = ApiModel.fromContext(context).api.event.detail(widget.eventId);
    _event = _eventApiClient.get();

    _cameras = availableCameras();
    _setupCameras();
  }

  void _setupCameras() {
    final camera = _cameras.then((cameras) => cameras[_currentCamera]);
    _cameraController = camera.then((camera) => CameraController(camera, ResolutionPreset.veryHigh));
    _cameraInit = _cameraController.then((controller) => controller.initialize());
  }

  void _takePicture() async {
      await _cameraInit;
      final image = await _cameraController.then((camera) => camera.takePicture());
      if (!context.mounted) return;
      setState(() => _flashbackPreview = File(image.path));
  }

  void _switchCamera() {
    setState(() {
      _currentCamera = _currentCamera == 0 ? 1 : 0;
    });

    final camera = _cameras.then((cameras) => cameras[_currentCamera]);
    camera.then((camera_) =>
        _cameraController.then((controller) => controller.setDescription(camera_))
    );
  }

  void _switchFlashMode() {
    setState(() =>
      _flashMode = _flashMode == FlashMode.off ? FlashMode.auto :
                   _flashMode == FlashMode.auto ? FlashMode.always : FlashMode.off
    );

    _cameraController.then((controller) => controller.setFlashMode(_flashMode));
  }

  void _handlePost() {
    if (_flashbackPreview == null) return;
    _eventApiClient.flashback.create(_flashbackPreview!);
    context.go("/home");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
        title: getFutureBuilder(_event, (event) => Text("${event.emoji.code} ${event.title}")),
        leading: IconButton(
            icon: const Icon(Symbols.arrow_back),
            onPressed: () => _flashbackPreview == null ? context.go("/home") : setState(() {
              _flashbackPreview = null;
            }),
        ),
        actions: [
          IconButton(onPressed: () => context.go("/event/${widget.eventId}"), icon: const Icon(Symbols.chat_bubble_outline))
        ],
      ),
      body: FutureBuilder(
          future: _cameraController,
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
          child: FutureBuilder(future: _cameraController, builder: (context, snapshot) {
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