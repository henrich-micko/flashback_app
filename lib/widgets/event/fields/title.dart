import 'package:flashbacks/utils/errors.dart';
import 'package:flutter/material.dart';


class TitleFieldCard extends StatefulWidget {
  final Function(String value) onChange;
  final FieldError? fieldError;
  const TitleFieldCard({super.key, required this.onChange, this.fieldError});

  @override
  State<TitleFieldCard> createState() => _TitleFieldCardState();
}

class _TitleFieldCardState extends State<TitleFieldCard> {
  final TextEditingController _titleController = TextEditingController();

  void _handleChange(String value) {
    setState(() => _titleController.text = value);
    widget.onChange(value);
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
          children: [_buildInfoSection(), _buildInputSection()],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, top: 8, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Title ", style: TextStyle(fontSize: 22.5)),

          if (widget.fieldError != null && widget.fieldError!.isActive)
            const Text("*", style: TextStyle(fontSize: 22.5, color: Colors.red)),
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
      child: TextField(
        controller: _titleController,
        onChanged: _handleChange,
        style: const TextStyle(color: Colors.white70, fontSize: 17),
        decoration: const InputDecoration(
          fillColor: Colors.black12,
          hintText: 'Set the title of your event.',
          filled: true,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w400),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
