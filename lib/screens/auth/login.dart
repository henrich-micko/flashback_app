import "package:flashbacks/providers/api.dart";
import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:go_router/go_router.dart";
import "package:provider/provider.dart";

enum _LoginScreenPage {
  username,
  password
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showError = false;
  _LoginScreenPage _page = _LoginScreenPage.username;

  void handleClickNext() {
    if (_page == _LoginScreenPage.username) {
      setState(() {
        _page = _LoginScreenPage.password;
      });
    }

    else if (_page == _LoginScreenPage.password) {
      Provider.of<ApiModel>(context, listen: false)
          .login(_usernameController.text, _passwordController.text)
          .then((_) => context.go("/home"))
          .catchError((error) => setState(() {
              _showError = true;
          })
      );
    }
  }

  void handleClickBack() {
    if (_page == _LoginScreenPage.username) {
      context.go("/");
    } else if (_page == _LoginScreenPage.password) {
      setState(() {
        _page = _LoginScreenPage.username;
      });
    }
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
        body: _page == _LoginScreenPage.username ? _buildUsernameBodySection() : _buildPasswordBodySection()
    );
  }

  Widget _buildUsernameBodySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const Gap(60),
        const Text("Enter your username? 🕵🏻‍♂️", style: TextStyle(fontSize: 20)),
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
        if (_showError)...[const Text("Zle️", style: TextStyle(fontSize: 20))],
        const Text("Enter your password 🔐", style: TextStyle(fontSize: 20)),
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