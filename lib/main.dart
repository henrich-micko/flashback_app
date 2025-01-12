import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/providers/notifications.dart';
import 'package:flashbacks/utils/api/token.dart';
import 'package:flashbacks/utils/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';


void main() async {
    await dotenv.load(fileName: ".env");
    WidgetsFlutterBinding.ensureInitialized();

    // read auth token
    Token? authToken = await readAuthToken();

    runApp(
        MultiProvider(
            providers: [
                ChangeNotifierProvider(create: (context) => ApiModel(authToken)),
                ChangeNotifierProvider(create: (context) => NotificationsModel()),
            ],
            child: const MyApp(),
        ),
    );
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
        ThemeData theme = ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.white, brightness: Brightness.dark, primary: Colors.white),
            useMaterial3: true,
            fontFamily: "Roboto",
            scaffoldBackgroundColor: const Color(0xff141218)
        );

        Widget app = MaterialApp.router(
            title: 'Flashbacks',
            theme: theme,
            routerConfig: router,
        );
      return app;
  }
}