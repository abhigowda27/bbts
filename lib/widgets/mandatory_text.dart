import 'package:bbts_server/main.dart';
import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

Widget richTxt({required String text, bool isMandatory = true}) {
  final context = navigatorKey?.currentContext;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: RichText(
        text: TextSpan(
            text: text,
            style: TextStyle(
              color: Theme.of(context!).appColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            children: [
          if (isMandatory) ...[
            TextSpan(
                text: " *",
                style: TextStyle(
                  color: Theme.of(context).appColors.redButton,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ))
          ]
        ])),
  );
}
