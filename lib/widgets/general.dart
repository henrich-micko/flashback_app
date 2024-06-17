import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SheetAction extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function()? onTap;

  const SheetAction({super.key, required this.title, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { if (onTap != null) onTap!(); },
      child: Row(
        children: [
          Icon(icon),
          const Gap(15),
          Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w400))
        ],
      ),
    );
  }
}