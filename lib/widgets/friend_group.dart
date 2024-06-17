import "package:flutter/material.dart";
import 'package:gap/gap.dart';

class FriendGroupBox extends StatelessWidget {
  const FriendGroupBox(
      {super.key,
      required this.title,
      required this.members,
      required this.profile});

  final String title;
  final int members;
  final String profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        buildProfile(),
        const Gap(5),
        Text(title, style: const TextStyle(color: Colors.white38)),
      ],
    );
  }

  Widget buildProfile() {
    final borderRadius = BorderRadius.circular(10); // Image border

    return Container(
      padding: const EdgeInsets.all(0), // Border width
      decoration:
          BoxDecoration(color: Colors.white, borderRadius: borderRadius),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox.fromSize(
          size: const Size.fromRadius(30), // Image radius
          child: Image.network(profile, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class FriendGroupBoxRow extends StatelessWidget {
  const FriendGroupBoxRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
        padding: EdgeInsets.only(top: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              FriendGroupBox(
                  title: "Mato",
                  members: 10,
                  profile:
                      "https://www.alexgrey.com/img/containers/art_images/Godself-2012-Alex-Grey-watermarked.jpeg/121e98270df193e56eeaebcff787023f.jpeg"),
              Gap(10),
              FriendGroupBox(
                  title: "Adam",
                  members: 10,
                  profile: "https://s38825.pcdn.co/wp-content/uploads/2018/09/9-13-18ChaneyAlex-GreyOversoul.jpg")
          ]),
        ));
  }
}

