import 'package:flashbacks/models/flashback.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api/client.dart';
import 'package:flashbacks/services/api/event.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flutter/cupertino.dart';

class FlashbackMedia extends StatelessWidget {
  final BasicFlashback flashback;
  final Uri mediaSource;

  const FlashbackMedia({super.key, required this.flashback, required this.mediaSource});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        child: SizedBox(
            height: 500,
            child: Image.network(mediaSource.resolve(flashback.media).toString())
        )
    );
  }
}

class EventFlashbacks extends StatefulWidget {
  final int eventId;

  const EventFlashbacks({super.key, required this.eventId});

  @override
  State<EventFlashbacks> createState() => _EventFlashbacksState();
}

class _EventFlashbacksState extends State<EventFlashbacks> {
  late EventApiDetailClient _eventApiClient;
  late Future<Iterable<BasicFlashback>> _flashbacks;

  @override
  void initState() {
    super.initState();
    _eventApiClient = ApiModel.fromContext(context).api.event.detail(widget.eventId);
    _flashbacks = _eventApiClient.flashback.all();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          getFutureBuilder(_flashbacks, (items) => FlashbackMedia(flashback: items.first, mediaSource: _eventApiClient.apiBaseUrl)),
        ],
      ),
    );
  }
}