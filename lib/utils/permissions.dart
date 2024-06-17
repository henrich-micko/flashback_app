import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/screens/auth/welcome_screen.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IsAuthenticated extends StatelessWidget {
  final Scaffold child;

  const IsAuthenticated({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiModel>(builder: (BuildContext context, ApiModel apiModel, Widget? child) =>
      getFutureBuilder(apiModel.isAuth, (isAuth) {
        if (isAuth) return this.child;
        return const WelcomeScreen();
      })
    );
  }
}