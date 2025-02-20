import "dart:io";

import "package:flashbacks/providers/api.dart";
import "package:flashbacks/utils/errors.dart";
import "package:flashbacks/var.dart";
import "package:flashbacks/widgets/fields/auth.dart";
import "package:flashbacks/widgets/fields/general.dart";
import "package:flashbacks/widgets/fields/user.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:gap/gap.dart";
import "package:go_router/go_router.dart";

const animationDurationMs = 250;

enum AuthScreenStage {
  welcome,
  login,
  register,
  setup,
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late ApiModel _apiModel;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AuthScreenStage _currAuthScreenStage = AuthScreenStage.welcome;

  // login inputs
  String? _loginUsername;
  final FieldError _loginUsernameFieldError = FieldError();
  String? _loginPassword;
  final FieldError _loginPasswordFieldError = FieldError();
  final FieldError _loginError = FieldError();


  // registration inputs
  String? _registerUsername;
  final FieldError _registerUsernameFieldError = FieldError();
  String? _registerEmail;
  final FieldError _registerEmailFieldError = FieldError();
  String? _registerPassword;
  String? _registerSubmitPassword;
  final FieldError _registerPasswordFieldError = FieldError();
  final FieldError _registerError = FieldError();

  late TabController _pageTabController;

  @override
  void initState() {
    super.initState();

    _apiModel = ApiModel.fromContext(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted && _currAuthScreenStage == AuthScreenStage.welcome) {
          _showBottomAuthMenuSection();
        }
      });
    });

    _pageTabController = TabController(length: 4, vsync: this);
    if (_currAuthScreenStage != AuthScreenStage.welcome)
      _pageTabController.animateTo(_currAuthScreenStage.index,
          duration: const Duration(milliseconds: animationDurationMs),
          curve: Curves.easeInOutQuart);
  }

  // Login section code

  void _handleLoginUsernameChange(String value) {
    setState(() {
      _loginUsername = value;
      _loginUsernameFieldError.isActive = false;
      _loginError.isActive = false;
    });
  }

  void _handleLoginPasswordChange(String value) {
    setState(() {
      _loginPassword = value;
      _loginPasswordFieldError.isActive = false;
      _loginError.isActive = false;
    });
  }

  void _handleLogin() {
    bool isValid = true;
    if (_loginUsername == null || _loginUsername!.isEmpty) {
      setState(() => _loginUsernameFieldError.isActive = true);
      isValid = false;
    }

    if (_loginPassword == null || _loginPassword!.isEmpty) {
      setState(() => _loginPasswordFieldError.isActive = true);
      isValid = false;
    }

    if (!isValid) return;

    _apiModel
        .login(_loginUsername!, _loginPassword!)
        .then((_) => context.go("/"))
        .catchError((error) => setState(() => _loginError.isActive = true));
  }

  // Register section code

  void _handleRegisterUsernameChange(String value) {
    setState(() {
      _registerUsername = value;
      _registerUsernameFieldError.isActive = false;
      _registerError.isActive = false;
    });
  }

  void _handleRegisterEmailChange(String value) {
    setState(() {
      _registerEmail = value;
      _registerEmailFieldError.isActive = false;
      _registerError.isActive = false;
    });
  }

  void _handleRegisterPasswordChange(String value) {
    setState(() {
      _registerPassword = value;
      _registerPasswordFieldError.isActive = false;
      _registerError.isActive = false;
    });
  }

  void _handleRegisterSubmitPasswordChange(String value) {
    setState(() {
      _registerSubmitPassword = value;
      _registerPasswordFieldError.isActive = false;
      _registerError.isActive = false;
    });
  }

  void _handleRegister() {
    bool isValid = true;
    if (_registerUsername == null || _registerUsername!.isEmpty) {
      setState(() => _registerUsernameFieldError.isActive = true);
      isValid = false;
    }

    if (_registerEmail == null || _registerEmail!.isEmpty) {
      setState(() => _registerEmailFieldError.isActive = true);
      isValid = false;
    }

    if (_registerPassword == null || _registerPassword!.isEmpty) {
      setState(() => _registerPasswordFieldError.isActive = true);
      isValid = false;
    }

    if (_registerSubmitPassword == null || _registerSubmitPassword!.isEmpty) {
      setState(() => _registerPasswordFieldError.isActive = true);
      isValid = false;
    }

    if (_registerSubmitPassword != _registerPassword) {
      setState(() => _registerPasswordFieldError.isActive = true);
      isValid = false;
    }

    if (!isValid) return;

    _apiModel
        .register(_registerEmail!, _registerUsername!, _registerPassword!)
        .then((cur) {
      _setCurrAuthScreenStage(AuthScreenStage.setup);
    }).catchError((errorData) {
      if (errorData != null) {
        setState(() {
          if (errorData['email'] != null) {
            _registerEmailFieldError.errorMessage = errorData['email'][0];
            _registerEmailFieldError.isActive = true;
          }
          if (errorData['username'] != null) {
            _registerUsernameFieldError.errorMessage = errorData['username'][0];
            _registerUsernameFieldError.isActive = true;
          }
          if (errorData['password'] != null) {
            _registerPasswordFieldError.errorMessage = errorData['password'][0];
            _registerPasswordFieldError.isActive = true;
          }
        });
      }
    });
  }

  // setup section code

  void _updateProfilePicture(File profilePicture) {
    _apiModel.updateProfilePicture(profilePicture);
  }

  // google auth section

  void _continueWithGoogle() {
    _apiModel.authWithGoogle().then((created) {
      if (created) {
        _setCurrAuthScreenStage(AuthScreenStage.setup);
      } else {
        context.go("/");
      }
    });
  }

  // general code

  void _setCurrAuthScreenStage(AuthScreenStage authScreenStage) {
    FocusScope.of(context).unfocus();

    if (_currAuthScreenStage == AuthScreenStage.welcome &&
        authScreenStage != AuthScreenStage.welcome) {
      Navigator.pop(context);
    } else if (_currAuthScreenStage != AuthScreenStage.welcome &&
        authScreenStage == AuthScreenStage.welcome) {
      _showBottomAuthMenuSection();
    }

    setState(() => _currAuthScreenStage = authScreenStage);

    _pageTabController.animateTo(_currAuthScreenStage.index,
        duration: const Duration(milliseconds: animationDurationMs),
        curve: Curves.easeInOutQuart);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.black,
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageTabController,
          children: [
            _buildWelcomeSection(),
            _buildLoginSection(),
            _buildRegistrationSection(),
            _buildSetupSection(),
          ],
        ));
  }

  Widget _buildLoginSection() {
    Size size = MediaQuery.of(context).size;

    return Container(
      key: const ValueKey(AuthScreenStage.login),
      child: Padding(
        padding:
            EdgeInsets.only(top: size.height / 100 * 25, left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionBar(
                "Sign in",
                () => _setCurrAuthScreenStage(AuthScreenStage.welcome),
                _handleLogin),
            const Gap(5),
            TextFieldCard(
                onChange: _handleLoginUsernameChange,
                label: "Username",
                fieldError: _loginUsernameFieldError),
            const Gap(10),
            TextFieldCard(
                onChange: _handleLoginPasswordChange,
                label: "Password",
                fieldError: _loginPasswordFieldError,
                password: true),
            if (_loginError.isActive)
              const Padding(
                padding: EdgeInsets.only(left: 15, top: 7.5),
                child: Text(
                  "Incorrect username or password. \nPlease try again.",
                  style: TextStyle(color: Color(0xFFFF4141)),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildSetupSection() {
    Size size = MediaQuery.of(context).size;

    return Container(
      key: const ValueKey(AuthScreenStage.setup),
      child: Padding(
        padding:
            EdgeInsets.only(top: size.height / 100 * 25, left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionBar("Setup", null, () => context.go("/"),
                leading: false),
            const Gap(10),
            UserPictureCardField(
                profilePicture: _apiModel.currUser != null
                    ? _apiModel.api.apiBaseUrl
                        .resolve(_apiModel.currUser!.profileUrl)
                        .toString()
                    : null,
                onChange: _updateProfilePicture),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationSection() {
    return Container(
      key: const ValueKey(AuthScreenStage.register),
      child: Padding(
        padding: const EdgeInsets.only(top: 50, left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionBar(
                "Sign up",
                () => _setCurrAuthScreenStage(AuthScreenStage.welcome),
                _handleRegister),
            const Gap(5),
            TextFieldCard(
                onChange: _handleRegisterUsernameChange,
                label: "Username",
                fieldError: _registerUsernameFieldError),
            const Gap(10),
            TextFieldCard(
                onChange: _handleRegisterEmailChange,
                label: "Email",
                fieldError: _registerEmailFieldError),
            const Gap(10),
            DoublePasswordFieldCard(
                onChange: _handleRegisterPasswordChange,
                onSubmitChange: _handleRegisterSubmitPasswordChange,
                fieldError: _registerPasswordFieldError),
            if (_registerError.isActive)
              const Padding(
                padding: EdgeInsets.only(left: 15, top: 7.5),
                child: Text(
                  "Incorrect username or password. \nPlease try again.",
                  style: TextStyle(color: Color(0xFFFF4141)),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    Size size = MediaQuery.of(context).size;

    return SizedBox(
      key: const ValueKey(AuthScreenStage.welcome),
      width: size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Gap(size.height / 100 * 20),
          SvgPicture.asset(
            'assets/images/welcome_flower.svg',
            height: 300,
            color: Colors.white,
          ),
          const Gap(75),
          const Text("Flashbacks",
              style: TextStyle(color: Colors.white, fontSize: 35)),
          const Text("Share memories with your friends",
              style: TextStyle(color: Colors.grey, fontSize: 17)),
        ],
      ),
    );
  }

  void _showBottomAuthMenuSection() {
    _scaffoldKey.currentState?.showBottomSheet(
      (context) => _buildBottomAuthMenuSection(),
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(
            milliseconds: animationDurationMs), // Set custom animation duration
      ),
    );
  }

  Widget _buildBottomAuthMenuSection() {
    return Container(
      decoration: const BoxDecoration(
        color: scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.only(top: 12, left: 14, right: 14),
      width: double.infinity,
      height: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                    onPressed: () =>
                        _setCurrAuthScreenStage(AuthScreenStage.login),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      side: const BorderSide(
                        color: Colors.white,
                        width: 0.75,
                      ),
                    ),
                    child: const Text("Sign in",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w400))),
              ),
              const Gap(7),
              Expanded(
                child: OutlinedButton(
                    onPressed: () =>
                        _setCurrAuthScreenStage(AuthScreenStage.register),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      side: const BorderSide(
                        color: Colors.white,
                        width: 0.75,
                      ),
                    ),
                    child: const Text("Sign up",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w400))),
              ),
            ],
          ),
          const Gap(5),
          FilledButton(
              onPressed: _continueWithGoogle,
              style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  padding: const EdgeInsets.only(top: 7, bottom: 7)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Continue with google",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: scaffoldBackgroundColor)),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildSectionBar(
      String label, Function()? onPrevTap, Function() onNextTap,
      {bool leading = true}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(
        children: [
          if (leading)
            IconButton(
                onPressed: onPrevTap,
                icon: const Icon(Icons.arrow_back),
                color: Colors.white),
          if (!leading) const Gap(15),
          Text(label, style: const TextStyle(fontSize: 27.5)),
        ],
      ),
      IconButton(
          onPressed: onNextTap,
          icon: const Icon(Icons.arrow_forward),
          color: Colors.white),
    ]);
  }
}
