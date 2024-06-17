import "package:flashbacks/providers/api.dart";
import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:go_router/go_router.dart";
import "package:logger/logger.dart";

enum _SignupScreenPage {
  email,
  username,
  password
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreen();
}

class _SignupScreen extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _showError = false;
  _SignupScreenPage _page = _SignupScreenPage.email;

  void handleClickNext() {
    if (_page == _SignupScreenPage.password) {
      ApiModel.fromContext(context)
          .register(
            _emailController.text,
            _usernameController.text,
            _passwordController.text
          )
          .then((_) => context.go("/home"))
          .catchError((error) => setState(() {
             _showError = true;
          }
        )
      );
    }

    else {
      setState(() {
        if (_page == _SignupScreenPage.email) _page = _SignupScreenPage.username;
        else if (_page == _SignupScreenPage.username) _page = _SignupScreenPage.password;
      });
    }
  }

  void handleClickBack() {
    if (_page == _SignupScreenPage.email) context.go("welcome");
    else {
      setState(() {
        if (_page == _SignupScreenPage.username) _page = _SignupScreenPage.email;
        else if (_page == _SignupScreenPage.password) _page = _SignupScreenPage.username;
      });
    }
  }

  // got o get paramater for updating
  Widget getCurrentScreen(_SignupScreenPage page) {
    if (page == _SignupScreenPage.email) return _buildEmailBodySection();
    if (page == _SignupScreenPage.username) return _buildUsernameBodySection();
    return _buildPasswordBodySection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Flashbacks ~//", style: TextStyle(fontSize: 30)),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: handleClickBack),
          actions: [
            IconButton(
                onPressed: handleClickNext,
                icon: const Icon(Icons.navigate_next_outlined))
          ],
        ),
        body: getCurrentScreen(_page)
    );
  }

  Widget _buildEmailBodySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const Gap(60),
        const Text("Whats your email? 📮", style: TextStyle(fontSize: 20)),
        TextField(
          controller: _emailController,
          onChanged: (value) => _emailController.text = value,
          textAlign: TextAlign.center,
          autofocus: true,
          style: const TextStyle(fontSize: 20),
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameBodySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const Gap(60),
        const Text("What will be your username? 🕵🏻‍♂️", style: TextStyle(fontSize: 20)),
        TextField(
          controller: _usernameController,
          onChanged: (value) => _usernameController.text = value,
          textAlign: TextAlign.center,
          autofocus: true,
          style: const TextStyle(fontSize: 20),
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordBodySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const Gap(60),
        if (_showError)...[const Text("Something went wrong...", style: TextStyle(fontSize: 20))],
        const Text("Set your self a strong password 🔐", style: TextStyle(fontSize: 20)),
        TextField(
          controller: _passwordController,
          onChanged: (value) => _passwordController.text = value,
          obscureText: true,
          textAlign: TextAlign.center,
          autofocus: true,
          style: const TextStyle(fontSize: 20),
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
        ),
      ],
    );
  }
}