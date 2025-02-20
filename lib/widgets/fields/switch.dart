import 'package:flutter/material.dart';


class SwitchCardField extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool value) onChange;

  const SwitchCardField({
    super.key,
    required this.label,
    required this.value,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card.outlined(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(left: 12.5, right: 7.5, top: 2.5, bottom: 2.5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabelSection(),
              _buildSwitchButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelSection() {
    return Text(label, style: const TextStyle(fontSize: 22.5));
  }

  Widget _buildSwitchButton() {
    return Switch(
      value: value,
      onChanged: onChange,
      activeColor: Colors.black,
      activeTrackColor: Colors.white,
      inactiveTrackColor: Colors.black,
      inactiveThumbColor: Colors.grey,
      splashRadius: 11,
      trackOutlineWidth: const MaterialStatePropertyAll<double?>(1),
    );
  }
}
