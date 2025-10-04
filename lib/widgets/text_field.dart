import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int? maxLength;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String query)? onChanged;
  final Icon? prefixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLength,
    this.suffixIcon,
    this.onChanged,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      obscureText: obscureText,
      maxLength: maxLength,
      onChanged: onChanged,
      keyboardType: keyboardType,
      contextMenuBuilder: null,
      style: Theme.of(context).textTheme.titleSmall,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(10),
          hintText: hintText,
          hintStyle: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(fontWeight: FontWeight.bold),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              color: Theme.of(context).appColors.grey,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              color: Theme.of(context).appColors.redButton,
              width: 1,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              color: Theme.of(context).appColors.redButton,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(
              color: Theme.of(context).appColors.primary,
              width: 2,
            ),
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon),
    );
  }
}
