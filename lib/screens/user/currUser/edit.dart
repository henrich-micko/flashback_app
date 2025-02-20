import 'dart:io';

import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/utils/errors.dart';
import 'package:flashbacks/widgets/fields/general.dart';
import 'package:flashbacks/widgets/fields/user.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class EditCurrUserScreen extends StatefulWidget {
  const EditCurrUserScreen({super.key});

  @override
  State<EditCurrUserScreen> createState() => _EditCurrUserScreenState();
}

class _EditCurrUserScreenState extends State<EditCurrUserScreen> {
  late ApiModel _apiModel;

  late String _username;
  late String? _about;

  final FieldError _usernameError = FieldError();

  @override
  void initState() {
    super.initState();

    _apiModel = ApiModel.fromContext(context);

    _username = _apiModel.currUser!.username;
    _about = _apiModel.currUser!.about;
  }

  void _updateProfilePicture(File profilePicture) {
    _apiModel.updateProfilePicture(profilePicture);
  }

  void _updateUsername() {
    final String value = _username.trim();
    if (value.isEmpty) {
      setState(() => _usernameError.isActive = true);
      return;
    }

    _apiModel.updateProfile({"username": value}).catchError((error) {
      setState(() {
        _usernameError.isActive = true;
        _usernameError.errorMessage = error["username"].first.toString();
      });
    }).then((_) =>
        setState(() {
          _apiModel = ApiModel.fromContext(context);
        })
    );
  }

  void _updateAbout() {
    String? value;
    if (_about != null) {
      value = _about!.trim().isEmpty ? null : _about!.trim();
    }

    _apiModel.updateProfile({"about": value}).then((_) =>
      setState(() {
        _apiModel = ApiModel.fromContext(context);
      })
    );
  }

  void _changeUsername(String value) {
    setState(() {
      _username = value;
      _usernameError.isActive = false;
      _usernameError.errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text("Edit Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            children: [
              _buildProfilePictureSection(),
              const Gap(10),
              _buildUsernameSection(),
              const Gap(10),
              _buildAboutSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return UserPictureCardField(
        profilePicture: _apiModel.currUser != null
            ? _apiModel.api.apiBaseUrl
                .resolve(_apiModel.currUser!.profileUrl)
                .toString()
            : null,
        onChange: _updateProfilePicture);
  }

  Widget _buildUsernameSection() {
    return TextFieldCard(
      onChange: _changeUsername,
      label: "Username",
      defaultValue: _apiModel.currUser?.username,
      fieldError: _usernameError,
      action: IconButton(
          icon: Icon(Symbols.save,
              color: _username == _apiModel.currUser?.username ||
                      _usernameError.isActive
                  ? Colors.grey
                  : Colors.white),
          onPressed: _updateUsername),
    );
  }

  Widget _buildAboutSection() {
    return TextFieldCard(
      onChange: (value) => setState(() => _about = value),
      label: "About me",
      defaultValue: _apiModel.currUser?.about,
      hintText: "Who are you? keep it short",
      action: IconButton(
          icon: Icon(Symbols.save,
              color: _about == _apiModel.currUser?.about
                  ? Colors.grey
                  : Colors.white),
          onPressed: _updateAbout),
    );
  }
}
