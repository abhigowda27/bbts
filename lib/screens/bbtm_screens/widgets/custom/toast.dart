import 'package:bbts_server/main.dart';
import 'package:flutter/material.dart';

void showToast(String text) {
  final context = navigatorKey.currentContext!;
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 1),
      content: Text(text),
      action: SnackBarAction(
          label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
    ),
  );
}
