
import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/models/flashback.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api_client.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flutter/cupertino.dart';

class FlashbackMedia extends StatelessWidget {
  static final ApiClient _apiClient = ApiClient();
  final BasicFlashback flashback;
  
  const FlashbackMedia({super.key, required this.flashback});

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
            child: Image.network(_apiClient.getUrl(flashback.media))
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
  late Future<ApiClient> _apiClient;
  late Future<Iterable<BasicFlashback>> _futureFlashbacks;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiModel.fromContext(context).api;
    _futureFlashbacks = _apiClient.then((api) => api.event.flashback.all(widget.eventId));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          getFutureBuilder(_futureFlashbacks, (items) => FlashbackMedia(flashback: items.first)),
        ],
      ),
    );
  }
}