import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/models/flashback.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api/event.dart';
import 'package:flashbacks/utils/time.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flashbacks/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';


class FlashbacksPackage extends StatefulWidget {
  final int eventId;
  const FlashbacksPackage({super.key, required this.eventId});

  @override
  State<FlashbacksPackage> createState() => _FlashbacksPackageState();
}

class _FlashbacksPackageState extends State<FlashbacksPackage> {
  late EventApiDetailClient _eventApiDetailClient;

  late Future<Event> _event;
  late Future<List<BasicFlashback>> _flashbacks;
  int currFlashback = 0;

  @override
  void initState() {
    super.initState();

    _eventApiDetailClient = ApiModel.fromContext(context).api.event.detail(
        widget.eventId
    );

    _event = _eventApiDetailClient.get();
    _flashbacks = _eventApiDetailClient.flashback.all().then((f) => f.toList());
  }

  void _handleNext() {
    setState(() => currFlashback += 1);
  }

  void _handleClose() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      color: Colors.black,
      width: size.width,
      height: size.height,
      child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Column(
          children: [
            _buildPackageEventHeader(),
            _buildFlashbackCard(),
            _buildUserProfileBottom(),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageEventHeader() {
    return getFutureBuilder(_event, (event) =>
      Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: const Icon(Symbols.close_rounded), onPressed: _handleClose),

            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(event.title, style: const TextStyle(color: Colors.white, fontSize: 20)),
                    if (currFlashback < event.flashbacksCount)
                      Text(
                        event.flashbacksCount == 0 ? "Zero flashbacks" : "${currFlashback + 1} of ${event.flashbacksCount} flashbacks",
                        style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),

                SizedBox(
                  width: 80,
                  child: Center(
                      child: Text(event.emoji.code, style: const TextStyle(fontSize: 40))),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }

  Widget _buildFlashbackCard() {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
      child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: SizedBox(
                height: size.height - 200,
                child: getFutureBuilder(_flashbacks, (flashbacks) {
                  if (currFlashback >= flashbacks.length)
                    return const Center(
                        child: Text("That's about it.", style: TextStyle(fontSize: 30))
                    );
                  return Image.network(
                    Uri.parse(
                        _eventApiDetailClient.apiBaseUrl.toString()
                    ).resolve(flashbacks[currFlashback].media).toString(),
                    fit: BoxFit.fitHeight,
                  );
                }),
            )
        ),
    );
  }

  Widget _buildUserProfileBottom() {
    return getFutureBuilder(_flashbacks, (flashbacks) {
      if (currFlashback >= flashbacks.length)
        return Container();
      return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  UserProfilePicture(profilePictureUrl: flashbacks[currFlashback].createdBy.profileUrl, size: 25),
                  const Gap(15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(flashbacks[currFlashback].createdBy.username,
                          style: const TextStyle(fontSize: 20, color: Colors.white)),
                      Text("Posted at ${timeFormat.format(flashbacks[currFlashback].createdAt)}",
                          style: const TextStyle(fontSize: 15, color: Colors.grey)),
                    ],
                  ),
                ],
              ),

              TextButton(onPressed: _handleNext, child: const Text("Next")),
            ],
          ),
        ),
      );}
    );
  }
}

void showModalBottomSheetFlashbacksPackage(BuildContext context, int eventId) {
  showModalBottomSheet(context: context, isScrollControlled: true, builder: (context) =>
    FlashbacksPackage(eventId: eventId)
  );
}