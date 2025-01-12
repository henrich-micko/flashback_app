import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/screens/auth/welcome.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';


class IsAuthenticated extends StatelessWidget {
  final Scaffold child;

  const IsAuthenticated({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiModel>(builder: (BuildContext context, ApiModel apiModel, Widget? child) {
      Logger().i(apiModel.isAuth ? "yes" : "no");
      return apiModel.isAuth ? this.child : const WelcomeScreen();
    });
  }
}