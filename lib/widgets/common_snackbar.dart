import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Theme.of(context).appColors.background,
      content: Row(
        children: [
          Icon(Icons.warning,
              color: Theme.of(context).appColors.redButton, size: 30),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).appColors.redButton,
                    fontSize: 15,
                    fontWeight: FontWeight.normal),
              ),
            ),
          )
        ],
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

void commonSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Theme.of(context).appColors.background,
      content: Row(
        children: [
          Icon(Icons.check_circle,
              color: Theme.of(context).appColors.green, size: 30),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).appColors.green,
                  fontSize: 15,
                  fontWeight: FontWeight.normal),
            ),
          )
        ],
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}
