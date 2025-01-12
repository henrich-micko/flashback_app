import 'package:flutter/material.dart';


String cleanErrorMessage(String errorMessage) {
  return errorMessage.replaceAll("[", "").replaceAll("]", "");
}


class FieldError {
  bool isActive;
  String? errorMessage;
  FieldError({this.isActive = false, this.errorMessage});

  Widget buildErrorMessage() {
    return ErrorMessage(errorMessage: errorMessage);
  }
}


class ErrorMessage extends StatelessWidget {
  final String? errorMessage;
  const ErrorMessage({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return errorMessage != null
        ? Text(errorMessage!, style: const TextStyle(fontSize: 17, color: Colors.red), textAlign: TextAlign.start)
        : Container();
  }
}
