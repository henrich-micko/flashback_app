import 'package:flutter/material.dart';
import 'package:gap/gap.dart';


enum NoEventPlaceHolderMode {
  past,
  future
}

class NoEventsPlaceHolder extends StatelessWidget {
  NoEventPlaceHolderMode mode;

  NoEventsPlaceHolder({
    super.key,
    this.mode = NoEventPlaceHolderMode.future
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Gap(200),

          if (mode == NoEventPlaceHolderMode.future)
            ..._buildFutureTerm()
          else
            ..._buildPastTerm()
        ],
      ),
    );
  }

  List<Widget> _buildFutureTerm() {
    return const [
      Text("You have no events planned", style: TextStyle(color: Colors.white, fontSize: 25)),
      Text("Create new ones or chill out this weekend", style: TextStyle(color: Colors.grey))
    ];
  }

  List<Widget> _buildPastTerm() {
    return const [
      Text("You have no past events", style: TextStyle(color: Colors.white, fontSize: 25)),
      Text("You can create new ones or check out your friends' events", style: TextStyle(color: Colors.grey))
    ];
  }
}