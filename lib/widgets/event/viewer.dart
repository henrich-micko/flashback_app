import 'dart:ui';

import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/models/flashback.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api/event.dart';
import 'package:flashbacks/utils/time.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flashbacks/widgets/event/package.dart';
import 'package:flashbacks/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class EventViewerCard extends StatefulWidget {
  final EventViewer eventViewer;
  final Uri mediaSourceServer;
  final Function()? onOpen;

  const EventViewerCard(
      {super.key, required this.eventViewer, required this.mediaSourceServer, this.onOpen});

  @override
  State<EventViewerCard> createState() => _EventViewerCardState();
}

class _EventViewerCardState extends State<EventViewerCard> {
  late EventApiDetailClient _eventApiClient;
  late Future<Iterable<EventMember>> _eventFriendsMembers;

  @override
  void initState() {
    super.initState();

    _eventApiClient = ApiModel.fromContext(context).api.event
        .detail(widget.eventViewer.event.id);
    _eventFriendsMembers = _eventApiClient.getFriendsMembers();
  }

  String _getPreviewFlashbackMediaUrl(EventPreviewFlashback epf) {
    return widget.mediaSourceServer.resolve(epf.media).toString();
  }

  void _handleTap(BuildContext context) async {
    if (!widget.eventViewer.isOpened) {
      _eventApiClient.markAsOpen();

      if (widget.onOpen != null) widget.onOpen!();
    }
    showModalBottomSheetFlashbacksPackage(context, widget.eventViewer.event.id);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.97;

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: SizedBox(
        height: 350,
        width: width,
        child: GestureDetector(
          onTap: () => _handleTap(context),
          child: Card.outlined(
              color: Colors.transparent,
              child: Column(
                children: [
                  _buildTopBar(),
                  _buildPreview(width),
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF424242), // Color of the bottom line
            width: 1, // Thickness of the bottom line
          ),
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 13),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: Row(
                    children: [
                      Text(widget.eventViewer.event.emoji.code,
                          style: const TextStyle(fontSize: 24)),
                      const Gap(10),
                      Text(widget.eventViewer.event.title,
                          style: const TextStyle(fontSize: 24)),
                    ],
                  ),
                ),
                getFutureBuilder(_eventFriendsMembers, (items) =>  UserStack(
                  usersProfilePicUrls: items
                      .map((f) => _eventApiClient.apiBaseUrl.resolve(f.user.profileUrl).toString())
                      .toList(),
                  size: 13,
                ))
              ],
            ),
            const Gap(3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(humanizePastDateTIme(widget.eventViewer.event.endAt),
                    style: const TextStyle(color: Colors.grey)),
                Text(
                    widget.eventViewer.flashbacksCount == 0
                        ? "No posts"
                        : "${widget.eventViewer.flashbacksCount} posts",
                    style: const TextStyle(color: Colors.grey))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(double width) {
    const double height = 260;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(11), bottomLeft: Radius.circular(11)),
      child: SizedBox(
        width: width,
        height: height,
        child: Row(
          children: [
            Flexible(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                      border: Border(
                    right: BorderSide(
                      color: Color(0xFF424242), // Border color
                      width: 0.5, // Border width
                    ),
                  )),
                  child: _wrapPreviewInLock(Image.network(
                    _getPreviewFlashbackMediaUrl(
                        widget.eventViewer.preview[0].flashback),
                    fit: BoxFit.cover,
                    width: width / 2,
                    height: height,
                  )),
                )),
            if (widget.eventViewer.preview.length != 1)
              Flexible(
                flex: 1,
                child: Column(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                              left: const BorderSide(
                                color: Color(0xFF424242), // Border color
                                width: 0.4, // Border width
                              ),
                              bottom: widget.eventViewer.preview.length == 3 ? const BorderSide(
                                color: Color(0xFF424242), // Border color
                                width: 0.4, // Border width
                              ) : BorderSide.none,
                            )),
                        child: _wrapPreviewInLock(Image.network(
                            _getPreviewFlashbackMediaUrl(
                                widget.eventViewer.preview[1].flashback),
                            fit: BoxFit.cover,
                            width: width / 2)),
                      ),
                    ),
                    if (widget.eventViewer.preview.length == 3)
                      Flexible(
                        flex: 1,
                        child: Container(
                          decoration: const BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: Color(0xFF424242), // Border color
                                  width: 0.4, // Border width
                                ),
                                top: BorderSide(
                                  color: Color(0xFF424242), // Border color
                                  width: 0.4, // Border width
                                ),
                              )),
                          child: _wrapPreviewInLock(Image.network(
                              _getPreviewFlashbackMediaUrl(
                                  widget.eventViewer.preview[2].flashback),
                              fit: BoxFit.cover,
                              width: width / 2)),
                        ),
                      ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _wrapPreviewInLock(Image preview) {
    if (widget.eventViewer.isOpened)
      return preview;

    return Stack(
      fit: StackFit.expand,
      children: [
        preview,
        ClipRRect( // Clip it cleanly.
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              alignment: Alignment.center,
              child: const Icon(Symbols.lock, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class EventViewerCardCollection extends StatefulWidget {
  final Iterable<EventViewer> eventViewers;
  final Function()? onOpen;

  const EventViewerCardCollection({super.key, required this.eventViewers, this.onOpen});

  @override
  State<EventViewerCardCollection> createState() =>
      _EventViewerCardCollectionState();
}

class _EventViewerCardCollectionState extends State<EventViewerCardCollection> {
  late EventApiClient _apiEventClient;

  @override
  void initState() {
    super.initState();

    _apiEventClient = ApiModel.fromContext(context).api.event;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Center(
        child: SizedBox(
            width: double.infinity,
            child: Column(
                    children: widget.eventViewers
                        .map((item) => EventViewerCard(
                            eventViewer: item,
                            mediaSourceServer: _apiEventClient.apiBaseUrl))
                        .toList())),
      ),
    );
  }
}
