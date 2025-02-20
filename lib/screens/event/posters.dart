import 'dart:typed_data';

import 'package:document_file_save_plus/document_file_save_plus.dart';
import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api/event.dart';
import 'package:flashbacks/utils/file.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:webview_flutter/webview_flutter.dart';


class EventPostersScreen extends StatefulWidget {
  int eventId;
  
  EventPostersScreen({
    super.key, 
    required this.eventId
  });

  @override
  State<EventPostersScreen> createState() => _EventPostersScreenState();
}

class _EventPostersScreenState extends State<EventPostersScreen> {
  late EventApiDetailClient _eventDetailApiClient;
  late EventApiClient _eventApiClient;
  
  late final Future<Iterable<EventPosterTemplate>> _posterTemplates;
  late final WebViewController _controller;

  bool _isLoading = true;
  EventPosterTemplate? _currTemplate;
  EventPosterColorPalette? _currColor;

  @override
  void initState() {
    super.initState();
  
    _eventApiClient = ApiModel.fromContext(context).api.event;
    _eventDetailApiClient = _eventApiClient.detail(widget.eventId);

    _posterTemplates = _eventApiClient.posterTemplates();
    _posterTemplates.then((templates) =>
        _loadPoster(templates.first, templates.first.colorPalettes.first)
    );

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  String _templateTitle(String title) {
    return title.replaceAll("_", " ").replaceFirst(title[0], title[0].toUpperCase());
  }

  void _loadPoster(EventPosterTemplate template, EventPosterColorPalette color) {
    setState(() => _isLoading = true);
    _eventDetailApiClient.generatePosterHtml(template.pk, color.pk).then((poster) {
      setState(() {
        _controller.loadHtmlString(poster);
        _isLoading = false;
        _currTemplate = template;
        _currColor = color;
      });
    });
  }

  void _downloadAndOpenPosterPdf() {
    if (_currTemplate == null || _currColor == null)
      return;

    _eventDetailApiClient.downloadPosterPdf(_currTemplate!.pk, _currColor!.pk);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
        title: const Text("Event posters"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop())
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20, top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: size.width,
                height: 550,
                child: getFutureBuilder(_posterTemplates, (templates) => _buildPoster())),

              _buildPostersTemplatesChipsSection(),

              if (_currTemplate != null)
                _buildPostersTemplatesColors(_currTemplate!)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoster() {
    return Center(
      child: SizedBox(
        width: 360,
        height: 505,
        child: Card.outlined(
          clipBehavior: Clip.hardEdge,
          child: Builder(builder: (context) {
            return WebViewWidget(controller: _controller);
          }),
        ),
      ),
    );
  }
  
  Widget _buildPostersTemplatesChipsSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          getFutureBuilder(_posterTemplates, (templates) =>
              Row(
                children: templates.map((template) =>
                    _buildPosterTemplateChip(template)
                ).toList(),
              )
            ),

          IconButton(onPressed: _downloadAndOpenPosterPdf, icon: const Icon(Symbols.download))
        ],
      )
      );
  }
  
  Widget _buildPosterTemplateChip(EventPosterTemplate template) {
    const borderSide = BorderSide(color: Colors.grey, width: 0.5);
    const activeBorderSide = BorderSide(color: Colors.white, width: 1);

    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: GestureDetector(
          onTap: () => _loadPoster(template, template.colorPalettes.first),
          child: Chip(
              backgroundColor: Colors.black,
              label: Text(_templateTitle(template.title)),
              side: _currTemplate == template ? activeBorderSide : borderSide
          )
      ),
    );
  }

  Widget _buildPostersTemplatesColors(EventPosterTemplate template) {
    return Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 15),
        child: getFutureBuilder(_posterTemplates, (templates) =>
            Row(
              children: template.colorPalettes.map((color) => Row(
                children: [
                  GestureDetector(
                    onTap: () => _loadPoster(template, color),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: _currColor == color ? Colors.white : Colors.grey, width: 1)
                      ),
                    ),
                  ),
                  const Gap(7),
                ],
              )
              ).toList(),
            )
        )
    );
  }

  Widget _buildLoading() {
    return const Center(child: Text("loading..."));
  }
}