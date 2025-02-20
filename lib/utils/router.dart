import 'package:flashbacks/screens/auth.dart';
import 'package:flashbacks/screens/auth/login.dart';
import 'package:flashbacks/screens/auth/signup.dart';
import 'package:flashbacks/screens/event/create.dart';
import 'package:flashbacks/screens/event/detail.dart';
import 'package:flashbacks/screens/event/list.dart';
import 'package:flashbacks/screens/event/members.dart';
import 'package:flashbacks/screens/event/options.dart';
import 'package:flashbacks/screens/event/posters.dart';
import 'package:flashbacks/screens/event/settings.dart';
import 'package:flashbacks/screens/flashback/create.dart';
import 'package:flashbacks/screens/flashback/detail.dart';
import 'package:flashbacks/screens/home.dart';
import 'package:flashbacks/screens/root.dart';
import 'package:flashbacks/screens/search.dart';
import 'package:flashbacks/screens/user/currUser/edit.dart';
import 'package:flashbacks/screens/user/detail.dart';
import 'package:flashbacks/screens/user/currUser/profile.dart';
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

enum SlideDirection {
  fromLeft,
  fromRight,
  fromBottom,
}

CustomTransitionPage slideTransitionPage(Widget child, SlideDirection slideDirection) {
  return CustomTransitionPage(
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const curve = Curves.easeInOut;

      final Offset begin;

      switch (slideDirection) {
        case SlideDirection.fromLeft:
          begin = const Offset(-1.0, 0.0);
          break;
        case SlideDirection.fromRight:
          begin = const Offset(1.0, 0.0);
          break;
        case SlideDirection.fromBottom:
          begin = const Offset(0.0, 1.0);
          break;
      }

      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

GoRouter getRouter(String initLocation) {
  return GoRouter(
    initialLocation: initLocation,
    routes: [
      GoRoute(
          path: "/",
          builder: (context, state) => const RootScreen(),
      ),

      GoRoute(
          name: "user-current",
          path: '/user/current',
          pageBuilder: (context, state) =>
              slideTransitionPage(const CurrUserDetailScreen(), SlideDirection.fromRight)
      ),

      GoRoute(
          name: "user-current-edit",
          path: '/user/current/edit',
          pageBuilder: (context, state) =>
              slideTransitionPage(const EditCurrUserScreen(), SlideDirection.fromRight)
      ),

      GoRoute(
          name: "auth",
          path: '/auth',
          pageBuilder: (context, state) =>
              noTransitionPage(const AuthScreen())
      ),

      GoRoute(
          name: "event-create",
          path: '/event/create',
          pageBuilder: (context, state) =>
              slideTransitionPage(
                  CreateEventScreen(), SlideDirection.fromRight
              )
      ),

      GoRoute(
          name: "event-detail",
          path: '/event/:eventId',
          pageBuilder: (context, state) =>
              slideTransitionPage(
                  EventDetailScreen(eventId: int.parse(state.pathParameters["eventId"]!)),
                  SlideDirection.fromRight,
              )
      ),

      GoRoute(
          name: "event-poster",
          path: '/event/:eventId/posters',
          pageBuilder: (context, state) =>
              slideTransitionPage(
                EventPostersScreen(eventId: int.parse(state.pathParameters["eventId"]!)),
                  SlideDirection.fromRight,
              )
      ),

      GoRoute(
          name: "event-options",
          path: '/event/:eventId/options',
          pageBuilder: (context, state) =>
              slideTransitionPage(
                EventOptionsScreen(eventPk: int.parse(state.pathParameters["eventId"]!)),
                SlideDirection.fromRight,
              )
      ),

      GoRoute(
          name: "event-settings",
          path: '/event/:eventId/settings',
          pageBuilder: (context, state) =>
              slideTransitionPage(
                  EventSettingsScreen(eventId: int.parse(state.pathParameters["eventId"]!)),
                  SlideDirection.fromRight
              )
      ),

      GoRoute(
          name: "event-members",
          path: '/event/:eventId/members',
          pageBuilder: (context, state) =>
              slideTransitionPage(
                  EditEventMembersScreen(eventId: int.parse(state.pathParameters["eventId"]!)),
                  SlideDirection.fromRight
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
          name: "user-detail",
          path: '/user/:userId',
          pageBuilder: (context, state) =>
              slideTransitionPage(UserDetailScreen(
                  userId: int.parse(state.pathParameters["userId"]!)
              ), SlideDirection.fromRight)

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
    ],
  );
}