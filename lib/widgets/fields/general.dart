import 'package:flashbacks/utils/errors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';


class TextFieldCard extends StatefulWidget {
  final String? defaultValue;
  final String label;
  final String? hintText;
  final Function(String value) onChange;
  final bool password;
  final FieldError? fieldError;
  final Widget? action;

  const TextFieldCard({
    super.key,
    required this.onChange,
    required this.label,
    this.hintText,
    this.fieldError,
    this.defaultValue,
    this.password=false,
    this.action
  });

  @override
  State<TextFieldCard> createState() => _TextFieldCardState();
}

class _TextFieldCardState extends State<TextFieldCard> {
  final TextEditingController _textInputController = TextEditingController();
  final FieldError? fieldError = null;

  @override
  void initState() {
    super.initState();
    if (widget.defaultValue != null)
      _textInputController.text = widget.defaultValue!;
  }

  void _handleChange(String value) {
    setState(() => _textInputController.text = value);
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
      padding: const EdgeInsets.only(left: 12.0, bottom: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Text(widget.label, style: const TextStyle(fontSize: 22.5)),
                    if (widget.fieldError != null && widget.fieldError!.isActive && widget.fieldError!.errorMessage == null)
                      const Text(" *", style: TextStyle(fontSize: 22.5, color: Colors.red))
                  ],
                ),
              ),

              if (widget.action != null)
                widget.action!
            ],
          ),
          if (widget.fieldError != null && widget.fieldError!.isActive && widget.fieldError!.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(widget.fieldError!.errorMessage!, style: const TextStyle(fontSize: 12.5, color: Colors.red)),
            ),
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
        obscureText: widget.password,
        controller: _textInputController,
        onChanged: _handleChange,
        style: const TextStyle(color: Colors.white70, fontSize: 17),
        decoration: InputDecoration(
          fillColor: Colors.black12,
          hintText: widget.hintText ?? "Set the ${widget.label.toLowerCase()}",
          filled: true,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w400),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
