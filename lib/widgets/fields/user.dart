import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';


class UserPictureCardField extends StatefulWidget {
  final String? profilePicture;
  final Function(File profilePicture)? onChange;

  const UserPictureCardField({super.key, required this.profilePicture, required this.onChange});

  @override
  State<UserPictureCardField> createState() => _UserPictureCardFieldState();
}

class _UserPictureCardFieldState extends State<UserPictureCardField> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
    if (widget.onChange != null) widget.onChange!(_image!);
  }

  @override
  Widget build(BuildContext context) {
    Logger().i(widget.profilePicture);

    return GestureDetector(
      onTap: _pickImage,
      child: Card.outlined(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoSection(),
            _buildProfileSection()
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return const Padding(
      padding: EdgeInsets.only(left: 12.0, top: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Profile picture", style: TextStyle(fontSize: 22.5)),
          Gap(6),
          Text("Tap to choose your profile\npicture", style: TextStyle(fontSize: 15, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _getProfilePicture() {
    if (_image != null)
      return CircleAvatar(
        radius: 35,
        backgroundImage: FileImage(_image!),
      );
    
    if (widget.profilePicture == null)
      return Container();
    
    return CircleAvatar(
      radius: 37.5,
      backgroundImage: NetworkImage(widget.profilePicture!),
    );
  }
  
  Widget _buildProfileSection() {
    return Container(
      decoration: const BoxDecoration(
          border: Border(
              left: BorderSide(
                width: 1,
                color: Color(0xFF424242),
              )
          ),
          color: Colors.transparent),
      width: 100,
      height: 100,
      child: Center(
          child: _getProfilePicture(),
    ));
  }
}

