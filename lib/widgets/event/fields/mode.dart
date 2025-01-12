import 'package:flashbacks/models/event.dart';
import 'package:flutter/material.dart';


class EventViewersModeFieldCard extends StatefulWidget {
  final EventViewersMode eventViewersMode;
  final double mutualFriendsLimit;

  final Function(EventViewersMode mode) onOptionChange;
  final Function(double value) onMFLChange;

  const EventViewersModeFieldCard({
    super.key,
    required this.eventViewersMode,
    required this.mutualFriendsLimit,
    required this.onOptionChange,
    required this.onMFLChange
  });

  @override
  State<EventViewersModeFieldCard> createState() => _EventViewersModeFieldCardState();
}

class _EventViewersModeFieldCardState extends State<EventViewersModeFieldCard> {
  late EventViewersMode _eventViewersMode;
  late double _mutualFriendsLimit;

  @override
  void initState() {
    super.initState();
    _eventViewersMode = widget.eventViewersMode;
    _mutualFriendsLimit = 30;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card.outlined(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoSection(), _buildInputSection()
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return const Padding(
      padding: EdgeInsets.only(left: 12.0, top: 8, bottom: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Flashbacks avalible for", style: TextStyle(fontSize: 22.5)),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(
                width: 1,
                color: Color(0xFF424242),
              )),
          color: Colors.transparent),
      child: Column(
      children: [
        _buildOption("Only members",
            EventViewersMode.onlyMembers,
                () => _eventViewersMode = EventViewersMode.onlyMembers),
        _buildOption("All friends of members",
            EventViewersMode.allFriends,
                () => _eventViewersMode = EventViewersMode.allFriends),
        _buildOption("Mutual friends of members",
            EventViewersMode.mutualFriends,
                () => _eventViewersMode = EventViewersMode.mutualFriends),

        if (_eventViewersMode == EventViewersMode.mutualFriends)
          _buildMutualFriendsSlider(),
      ],
      )
    );
  }

  Widget _buildOption(String label, EventViewersMode mode, Function() onChange) {
    return ListTile(
      title: Text(label),
      leading: Radio<String>(
        value: mode.name,
        groupValue: _eventViewersMode.name,
        onChanged: (_) {
          widget.onOptionChange(mode);
          setState(() => onChange());
        })
      );
  }

  Widget _buildMutualFriendsSlider() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, bottom: 15, right: 15, top: 10),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text("Set with how many percent of members you have to be friends with",
                style: TextStyle(fontSize: 15, color: Colors.grey), textAlign: TextAlign.start),
            Slider(
                min: 10,
                max: 100,
                value: _mutualFriendsLimit,
                label: "${_mutualFriendsLimit.round()}%",
                divisions: 9,
                onChanged: (value) {
                  widget.onMFLChange(value / 100);
                  setState(() => _mutualFriendsLimit = value);
                }),
          ],
        ),
      ),
    );
  }
}
