import 'package:flutter/material.dart';


class OptionGroup extends StatelessWidget {
  final List<OptionGroupItem> children;
  final bool isDanger;
  const OptionGroup({super.key, required this.children, this.isDanger = false});

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: isDanger ? const Color(0xFFFF7A7A) : Colors.grey, width: 1), // Red outline
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}


class OptionGroupItem extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Function() onTap;
  double fontSize;

  OptionGroupItem({
    super.key, required this.label, this.icon, required this.onTap, this.fontSize = 22
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: fontSize, color: Colors.white)),
            if (icon != null)
              Icon(icon, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

