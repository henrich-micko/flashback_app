import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:gap/gap.dart";
import "package:go_router/go_router.dart";


class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text("Flashbacks ~//", style: TextStyle(fontSize: 30)),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Gap(60),
            const Text("Do you have an account 🤔 ??", style: TextStyle(fontSize: 20)),
            const Gap(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(onPressed: () => context.go("/auth/login/"), child: const Text("Yep", style: TextStyle(fontSize: 19, color: Colors.white))),
                const Gap(10),
                TextButton(onPressed: () => context.go("/auth/signup"), child: const Text("Nope", style: TextStyle(fontSize: 19, color: Colors.white))),
              ],
            )
          ],
        ),
      ),
    );
  }
}