import 'package:flashbacks/utils/errors.dart';
import 'package:flutter/material.dart';

class DoublePasswordFieldCard extends StatefulWidget {
  final Function(String value) onChange;
  final Function(String value) onSubmitChange;
  final FieldError? fieldError;

  const DoublePasswordFieldCard({
    super.key,
    required this.onChange,
    required this.onSubmitChange,
    this.fieldError,
  });

  @override
  State<DoublePasswordFieldCard> createState() =>
      _DoublePasswordFieldCardState();
}

class _DoublePasswordFieldCardState extends State<DoublePasswordFieldCard> {
  final TextEditingController _passwordInputController =
      TextEditingController();
  final TextEditingController _passwordSubmitInputController =
      TextEditingController();
  final FieldError? fieldError = null;

  void _handleChange(String value) {
    setState(() => _passwordInputController.text = value);
    widget.onChange(value);
  }

  void _handleSubmitChange(String value) {
    setState(() => _passwordSubmitInputController.text = value);
    widget.onSubmitChange(value);
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Password", style: TextStyle(fontSize: 22.5)),
              if (_passwordInputController.text != _passwordSubmitInputController.text || widget.fieldError != null && widget.fieldError!.isActive && widget.fieldError!.errorMessage == null)
                const Text(" *", style: TextStyle(fontSize: 22.5, color: Colors.red))
            ],
          ),
          if (widget.fieldError!.isActive && widget.fieldError!.errorMessage != null)
            Text(widget.fieldError!.errorMessage!, style: const TextStyle(fontSize: 12.5, color: Colors.red)),
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
          TextField(
            obscureText: true,
            controller: _passwordInputController,
            onChanged: _handleChange,
            style: const TextStyle(color: Colors.white70, fontSize: 17),
            decoration: const InputDecoration(
              fillColor: Colors.black12,
              hintText: "Set the password",
              filled: true,
              hintStyle: TextStyle(
                  color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w400),
              border: InputBorder.none,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(
                      width: 1,
                      color: Color(0xFF424242),
                    )),
                color: Colors.transparent),
            child: TextField(
              obscureText: true,
              controller: _passwordSubmitInputController,
              onChanged: _handleSubmitChange,
              style: const TextStyle(color: Colors.white70, fontSize: 17),
              decoration: const InputDecoration(
                fillColor: Colors.black12,
                hintText: "Submit the password",
                filled: true,
                hintStyle: TextStyle(
                    color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w400),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
