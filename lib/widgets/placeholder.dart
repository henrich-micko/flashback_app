import 'package:flutter/material.dart';


class NoEventsPlaceHolder extends StatelessWidget {
  const NoEventsPlaceHolder({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("🌴", style: TextStyle(fontSize: 100)),
          Text("You have no events planned", style: TextStyle(color: Colors.white, fontSize: 25)),
          Text("Create new ones or chill out this weekend", style: TextStyle(color: Colors.grey))
        ],
      ),
    );
  }
}