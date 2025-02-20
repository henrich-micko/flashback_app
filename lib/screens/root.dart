import "package:flashbacks/screens/event/list.dart";
import "package:flashbacks/screens/home.dart";
import "package:flashbacks/screens/search.dart";
import "package:flashbacks/screens/user/currUser/profile.dart";
import "package:flutter/material.dart";


class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final PageController _controller = PageController(initialPage: 1);

  void _animateToPage(int index) {
    FocusScope.of(context).unfocus();
    _controller.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
        controller: _controller,
        children: [
          SearchScreen(goRight: () => _animateToPage(1)),
          HomeScreen(
            goLeft: () => _animateToPage(0),
            goRight: () => _animateToPage(2),
          ),
          EventListScreen(goLeft: () => _animateToPage(1))
        ],
    );
  }
}
