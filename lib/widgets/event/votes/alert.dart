import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class VotesAlert extends StatelessWidget {
  const VotesAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.95,
        height: 90,
        child: const Card.outlined(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("✨ New votes",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400)),
              Text("Lets change that! ",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300))
            ],
          ),
        ),
    );
  }
}
