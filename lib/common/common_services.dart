import 'package:flutter/material.dart';

class CommonServices {
  // Show Loading Dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3), // dimmed background
      builder: (BuildContext context) {
        return const PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero, // remove default padding
            child: SizedBox.expand(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        );
      },
    );
  }

  // Hide Loading Dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // Show No Data Widget
  static Widget noDataWidget() {
    return Center(
      child: Image.asset("assets/images/no_data_found.png"),
    );
  }

  // Show Failure Widget
  static Widget failureWidget(final VoidCallback? onRetry) {
    return Column(
      children: [
        Image.asset("assets/images/something_went_wrong.png"),
        ElevatedButton(onPressed: onRetry, child: const Text("Retry"))
      ],
    );
  }

  // Optional: Show a Snackbar for errors
  static void showSnackBar(BuildContext context, String message,
      {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
