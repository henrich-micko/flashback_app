import 'package:flashbacks/screens/auth/login.dart';
import 'package:flashbacks/screens/auth/signup.dart';
import 'package:flashbacks/screens/auth/welcome.dart';
import 'package:flashbacks/screens/event/create.dart';
import 'package:flashbacks/screens/event/detail.dart';
import 'package:flashbacks/screens/event/list.dart';
import 'package:flashbacks/screens/flashback/create.dart';
import 'package:flashbacks/screens/flashback/detail.dart';
import 'package:flashbacks/screens/home.dart';
import 'package:flashbacks/screens/notifications.dart';
import 'package:flashbacks/screens/user/detail.dart';
import 'package:flashbacks/screens/user/me.dart';
import 'package:flashbacks/screens/user/search.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';


CustomTransitionPage noTransitionPage(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}


final router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(name: "home", path: '/home', pageBuilder: (context, state) => noTransitionPage(const HomeScreen())),

    GoRoute(
        name: "user-me",
        path: '/user/me',
        pageBuilder: (context, state) =>
            noTransitionPage(const MeScreen())
    ),

    GoRoute(
        name: "welcome",
        path: '/welcome',
        pageBuilder: (context, state) =>
            noTransitionPage(
                const WelcomeScreen(),
            )
    ),

    GoRoute(
        name: "event-list",
        path: '/event/list',
        pageBuilder: (context, state) =>
            noTransitionPage(
              const EventListScreen(),
            )
    ),

    GoRoute(
        name: "event-create",
        path: '/event/create',
        pageBuilder: (context, state) =>
            noTransitionPage(
                CreateEventScreen()
            )
    ),

    GoRoute(
        name: "event-create-advanced-settings",
        path: '/event/create/:eventId/advanced-settings',
        pageBuilder: (context, state) =>
            noTransitionPage(
              CreateEventAdvancedSettings(
                  eventId: int.parse(state.pathParameters["eventId"]!)
              ),
            )
    ),

    GoRoute(
        name: "add-people-to-event",
        path: '/event/create/:eventId/edit-people',
        pageBuilder: (context, state) =>
            noTransitionPage(
                CreateEventAddPeopleScreen(eventPk: int.parse(state.pathParameters["eventId"]!))
            )
    ),

    GoRoute(
        name: "event-detail",
        path: '/event/:eventId',
        pageBuilder: (context, state) =>
            noTransitionPage(
                EventDetailScreen(eventId: int.parse(state.pathParameters["eventId"]!))
            )
    ),

    GoRoute(
        name: "login",
        path: '/auth/login',
        pageBuilder: (context, state) =>
            noTransitionPage(const LoginScreen())
    ),

    GoRoute(
        name: "signup",
        path: '/auth/signup',
        pageBuilder: (context, state) =>
            noTransitionPage(const SignupScreen())
    ),

    GoRoute(
        name: "search",
        path: '/user/search',
        pageBuilder: (context, state) =>
            noTransitionPage(const SearchScreen())
    ),

    GoRoute(
        name: "user-detail",
        path: '/user/:userId',
        pageBuilder: (context, state) =>
            noTransitionPage(UserScreen(
                userId: int.parse(state.pathParameters["userId"]!),
                goBack: state.extra.toString(), // TODO: FIX THIS HORRIBLE APROACH (navigator.pop doesnt work)
            ))
    ),

    GoRoute(
        name: "event-create-flashback",
        path: '/event/:eventId/flashback/create',
        pageBuilder: (context, state) =>
            noTransitionPage(
              CreateFlashbackScreen(
                  eventId: int.parse(state.pathParameters["eventId"]!)
              ),
            )
    ),

    GoRoute(
        name: "event-detail-flashback",
        path: '/event/:eventId/flashback',
        pageBuilder: (context, state) =>
            noTransitionPage(
              DetailFlashbackScreen(
                  eventId: int.parse(state.pathParameters["eventId"]!)
              ),
            )
    ),

    GoRoute(
        name: "notifications",
        path: '/notifications',
        pageBuilder: (context, state) =>
            noTransitionPage(const NotificationsScreen())
    ),
  ],
);