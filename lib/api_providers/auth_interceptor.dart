import 'package:bbts/api_providers/dio_client.dart';
import 'package:bbts/controllers/shared_preference.dart';
import 'package:bbts/main.dart';
import 'package:bbts/screens/account_register.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final SharedPreferenceServices preferences;

  AuthInterceptor({
    required this.dio,
    required this.preferences,
  });

  bool _isShowingLogoutDialog = false;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _handleUnauthorized();
    }

    handler.next(err);
  }

  Future<void> _handleUnauthorized() async {
    if (_isShowingLogoutDialog) {
      return;
    }

    _isShowingLogoutDialog = true;

    try {
      final context = navigatorKey.currentContext;

      if (context == null) {
        return;
      }

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Session Expired'),
            content: const Text(
              'Your session has expired. Please login again.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      await _logout();
    } finally {
      _isShowingLogoutDialog = false;
    }
  }

  Future<void> _logout() async {
    await DioClient().clearCookies();
    await preferences.saveLoggedInStatus(false);

    Navigator.pushAndRemoveUntil(
      navigatorKey.currentContext!,
      MaterialPageRoute(
        builder: (context) => const RegisterPage(),
      ),
      (route) => false,
    );
  }
}
