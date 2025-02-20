import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/models/flashback.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api/event.dart';
import 'package:flashbacks/utils/time.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flashbacks/widgets/flashback.dart';
import 'package:flutter/material.dart';
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
  late EventApiDetailClient _eventApiClient;
  late Future<Iterable<BasicFlashback>> _flashbacks;
  late Future<Event> _event;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _eventApiClient = ApiModel.fromContext(context).api.event.detail(widget.eventId);
    _event = _eventApiClient.get();
    _flashbacks = _eventApiClient.flashback.all();

    _flashbacks.then((flashbacks) {
      if (flashbacks.isEmpty)
        context.go("/event/${widget.eventId}");
    });
  }

  void _handleNext() {
    setState(() {
      _flashbacks.then((fbs) {
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
      _flashbacks.then((fbs) {
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
        title: getFutureBuilder(_event, (event) => Text("${event.emoji.code} ${event.title}", style: const TextStyle(fontSize: 35))),
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: () => context.go("/home")
          ,
        )
      ),
      body:
      getFutureBuilder(_flashbacks, (items) => Column(
        children: [
          const Gap(40),
          Center(child: FlashbackMedia(flashback: items.elementAt(_currentIndex), mediaSource: _eventApiClient.apiBaseUrl)),

          Padding(
            padding: const EdgeInsets.all(50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: _handlePrev, icon: const Icon(Icons.arrow_back_ios)),
                getFutureBuilder(_event, (event) => Column(
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