import 'package:bbts_server/main.dart';
import 'package:flutter/material.dart';

void showToast(String text) {
  final context = navigatorKey.currentContext!;
  final scaffold = ScaffoldMessenger.of(context);
  ScaffoldMessenger.of(navigatorKey.currentContext!).hideCurrentSnackBar();

  scaffold.showSnackBar(
    SnackBar(
      dismissDirection: DismissDirection.vertical,
      duration: const Duration(seconds: 2),
      content: Text(text),
      action: SnackBarAction(
          label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
    ),
  );
}
