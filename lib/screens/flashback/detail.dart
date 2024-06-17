import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/models/flashback.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api_client.dart';
import 'package:flashbacks/utils/time.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flashbacks/widgets/flashback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class DetailFlashbackScreen extends StatefulWidget {
  final int eventId;

  const DetailFlashbackScreen({super.key, required this.eventId});

  @override
  State<DetailFlashbackScreen> createState() => _DetailFlashbackScreenState();
}

class _DetailFlashbackScreenState extends State<DetailFlashbackScreen> {
  late Future<ApiClient> _apiClient;
  late Future<Iterable<BasicFlashback>> _futureFlashbacks;
  late Future<Event> _futureEvent;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiModel.fromContext(context).api;
    _futureFlashbacks = _apiClient.then((api) => api.event.flashback.all(widget.eventId));
    _futureEvent = _apiClient.then((api) => api.event.get(widget.eventId));

    _futureFlashbacks.then((flashbacks) {
      if (flashbacks.isEmpty) context.go("/event/${widget.eventId}");
    });
  }

  void _handleNext() {
    setState(() {
      _futureFlashbacks.then((fbs) {
        if (_currentIndex >= fbs.length - 1) {
          _currentIndex = 0;
        } else {
          _currentIndex ++;
        }
      });
    });
  }

  void _handlePrev() {
    setState(() {
      _futureFlashbacks.then((fbs) {
        if (_currentIndex <= 0) {
          _currentIndex = fbs.length - 1;
        } else {
          _currentIndex --;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: getFutureBuilder(_futureEvent, (event) => Text("${event.emoji.code} ${event.title}", style: const TextStyle(fontSize: 35))),
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: () => context.go("/home")
          ,
        )
      ),
      body:
      getFutureBuilder(_futureFlashbacks, (items) => Column(
        children: [
          const Gap(40),
          Center(child: FlashbackMedia(flashback: items.elementAt(_currentIndex))),

          Padding(
            padding: const EdgeInsets.all(50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: _handlePrev, icon: const Icon(Icons.arrow_back_ios)),
                getFutureBuilder(_futureEvent, (event) => Column(
                  children: [
                    Text("By ${items.elementAt(_currentIndex).createdBy.username}", style: const TextStyle(fontSize: 25)),
                    Text(dateFormat.format(items.elementAt(_currentIndex).createdAt), style: const TextStyle(fontSize: 17)),
                  ],
                )),
                IconButton(onPressed: _handleNext, icon: const Icon(Icons.arrow_forward_ios))
              ],
            ),
          )
        ],
      ))
    );
  }
}