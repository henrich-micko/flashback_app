import "package:flutter/material.dart";


class NoEventHolder extends StatelessWidget {
  final Function()? onTap;

  const NoEventHolder({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GestureDetector(
        onTap: () {
          if (onTap != null) onTap!();
        },
        child: const Card.outlined(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("✨ No Events Planned",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400)),
              Text("Lets change that! ",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300))
            ],
          ),
        ),
      ),
    );
  }
}