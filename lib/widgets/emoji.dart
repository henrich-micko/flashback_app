import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as picker;

class EmojiBox extends StatelessWidget {
  Function? onTap;
  Emoji emoji;
  double height;
  double width;

  EmojiBox({super.key, required this.emoji, this.onTap, this.height = 80, this.width = 80});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () { if (onTap != null) onTap!(); },
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.white,
            ),
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12)),
        width: width,
        height: height,
        child: Center(
            child: Text(emoji.code, style: const TextStyle(fontSize: 45))),
      ),
    );
  }
}

class EmojiField extends StatefulWidget {
  final Emoji defaultEmoji;
  final emojiParser = EmojiParser();
  final Function(Emoji value)? onChange;

  EmojiField({super.key, this.onChange, required this.defaultEmoji});

  @override
  State<EmojiField> createState() => _EmojiFieldState();
}

class _EmojiFieldState extends State<EmojiField> {
  late Emoji selectedEmoji;

  @override
  void initState() {
    super.initState();
    selectedEmoji = widget.defaultEmoji;
  }

  void handleSelect(picker.Category? category, picker.Emoji emoji) {
    var parsedEmoji = widget.emojiParser.getEmoji(emoji.emoji);
    if (parsedEmoji == Emoji.None) return;

    setState(() => selectedEmoji = widget.emojiParser.getEmoji(emoji.emoji));
    if (widget.onChange != null) widget.onChange!(selectedEmoji);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return EmojiBox(emoji: selectedEmoji, onTap: showSelectPopup);
  }

  Future showSelectPopup() async {
    showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
              height: 350,
              color: Colors.black26,
              child: Card(
                child: picker.EmojiPicker(
                  onEmojiSelected: handleSelect,
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
}
