import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/providers/notifications.dart';
import 'package:flashbacks/utils/api/token.dart';
import 'package:flashbacks/utils/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';


void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    WebViewPlatform.instance;

    await dotenv.load(fileName: ".env");
    WidgetsFlutterBinding.ensureInitialized();

    // read auth token
    Token? authToken = await readAuthToken();

    await FlutterDownloader.initialize(
        debug: true,
        ignoreSsl: true
    );

    runApp(
        MultiProvider(
            providers: [
                ChangeNotifierProvider(create: (context) => ApiModel(authToken)),
                ChangeNotifierProvider(create: (context) => NotificationsModel()),
            ],
            child: MyApp(isAuth: authToken != null),
        ),
    );
}

class MyApp extends StatelessWidget {
    final bool isAuth;
    const MyApp({super.key, required this.isAuth});

    @override
    Widget build(BuildContext context) {
        ThemeData theme = ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.white, brightness: Brightness.dark, primary: Colors.white),
            useMaterial3: true,
            fontFamily: "lexend",
            scaffoldBackgroundColor: Colors.black
        );

        Widget app = MaterialApp.router(
            title: 'Flashbacks',
            theme: theme,
            routerConfig: getRouter(isAuth ? "/" : "/auth/"),
        );
      return app;
  }
}