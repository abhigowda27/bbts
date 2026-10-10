import 'package:bbts/main.dart';
import 'package:bbts/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ToastType {
  success,
  error,
  warning,
  info,
}

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

void showFlutterToast(
  String msg, {
  ToastType type = ToastType.info,
  Toast len = Toast.LENGTH_LONG,
}) {
  Fluttertoast.cancel();

  Color backgroundColor;

  switch (type) {
    case ToastType.success:
      backgroundColor = Colors.green.withValues(alpha: 0.8);
      break;

    case ToastType.error:
      backgroundColor = Colors.redAccent.withValues(alpha: 0.8);
      break;

    case ToastType.warning:
      backgroundColor = Colors.orange.withValues(alpha: 0.8);
      break;

    case ToastType.info:
      backgroundColor =
          Theme.of(navigatorKey.currentContext!).appColors.textSecondary;
      break;
  }

  Fluttertoast.showToast(
    msg: msg,
    toastLength: len,
    backgroundColor: backgroundColor,
    textColor: Theme.of(navigatorKey.currentContext!).appColors.background,
  );
}
