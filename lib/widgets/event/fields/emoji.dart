import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as picker;
import 'package:gap/gap.dart';


class EmojiCardField extends StatefulWidget {
  final Emoji defaultEmoji;
  final emojiParser = EmojiParser();
  double size = 100;
  final Function(Emoji value)? onChange;

  EmojiCardField({super.key, required this.defaultEmoji, required this.onChange});

  @override
  State<EmojiCardField> createState() => _EmojiCardFieldState();
}

class _EmojiCardFieldState extends State<EmojiCardField> {
  late Emoji _selectedEmoji;

  void _onTap() {
    _showSelectPopup();
  }

  void _handleSelect(picker.Category? category, picker.Emoji emoji) {
    var parsedEmoji = widget.emojiParser.getEmoji(emoji.emoji);
    if (parsedEmoji == Emoji.None) return;

    setState(() => _selectedEmoji = widget.emojiParser.getEmoji(emoji.emoji));
    if (widget.onChange != null) widget.onChange!(_selectedEmoji);
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _selectedEmoji = widget.defaultEmoji;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Card.outlined(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoSection(),
            _buildEmojiPickerSection()
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return const Padding(
      padding: EdgeInsets.only(left: 12.0, top: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Emoji profile", style: TextStyle(fontSize: 22.5)),
          Gap(6),
          Text("Tap to choose an emoji that\nrepresent your event!", style: TextStyle(fontSize: 15, color: Colors.grey)),
        ],
      ),
    );
  }

  Future _showSelectPopup() async {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
          height: 350,
          color: Colors.black26,
          child: Card(
              child: picker.EmojiPicker(
                onEmojiSelected: _handleSelect,
                config: const picker.Config(
                  bgColor: Colors.black26,
                  columns: 7,
                  iconColorSelected: Colors.blue,
                ),
              )
          )
      ),
    );
  }

  Widget _buildEmojiPickerSection() {
    return Container(
      decoration: const BoxDecoration(
          border: Border(
              left: BorderSide(
                width: 1,
                color: Color(0xFF424242),
              )
          ),
          color: Colors.transparent),
      width: widget.size,
      height: widget.size,
      child: Center(
          child: Text(_selectedEmoji.code, style: TextStyle(fontSize: widget.size / 1.77))),
    );
  }
}

