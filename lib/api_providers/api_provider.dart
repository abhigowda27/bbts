import 'dart:convert';

import 'package:bbts_server/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../common/get_device_id.dart';
import '../common/globals.dart' as globals;
import '../controllers/shared_preference.dart';

class ApiProvider {
  final deviceId = DeviceUtils.getDeviceId();
  late String authCookie;
  final Dio _dio = Dio(BaseOptions(
    baseUrl: Constants.apiEndPoint,
    headers: {
      'Content-Type': 'application/json',
      "deviceid": globals.deviceId ?? ''
    },
  ));

  Future<dynamic> login(Map<String, dynamic> payload) async {
    debugPrint("Payload Passing to Api=====> $payload");
    debugPrint(">>>>>>>>>${_dio.options.headers}");
    try {
      final response = await _dio
          .post(
            '/api/auth/login',
            data: payload,
          )
          .timeout(const Duration(seconds: 5));
      final setCookie = response.headers.map['set-cookie']?.first;
      if (setCookie != null) {
        authCookie = setCookie.split(';').first;
        debugPrint("Saved Cookie: $authCookie");
        await SharedPreferenceServices().saveAuthCookie(authCookie);
      }
      debugPrint("Api Response=====> $response");
      debugPrint("Api ResponseData=====> ${response.data}");
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Login failed: ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('error: $e');
    }
  }

  Future<dynamic> addSwitch(Map<String, dynamic> payload) async {
    debugPrint("Payload Passing to Api=====> ${jsonEncode(payload)}");
    String? savedCookie = SharedPreferenceServices().getAuthCookie();
    debugPrint("Header Passing to Api=====>$savedCookie");
    try {
      final response = await _dio
          .post(
            '/api/devices/add',
            data: payload,
            options: Options(
              headers: {
                'Cookie': savedCookie,
              },
            ),
          )
          .timeout(const Duration(seconds: 5));
      debugPrint("Api Response=====> $response");

      debugPrint("Api ResponseData=====> ${response.data}");
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Add Switch failed: ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('error: $e');
    }
  }

  Future<dynamic> getSwitchList() async {
    String? savedCookie = SharedPreferenceServices().getAuthCookie();
    debugPrint("Header Passing to Api=====>$savedCookie");
    try {
      final response = await _dio
          .get(
            '/api/devices/list',
            data: {},
            options: Options(
              headers: {
                'Cookie': savedCookie,
              },
            ),
          )
          .timeout(const Duration(seconds: 5));
      debugPrint("Api Response=====> $response");

      debugPrint("Api ResponseData=====> ${response.data}");
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Add Switch failed: ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<dynamic> triggerSwitch(Map<String, dynamic> payload) async {
    debugPrint("Payload Passing to Api=====> ${jsonEncode(payload)}");
    String? savedCookie = SharedPreferenceServices().getAuthCookie();
    debugPrint("Header Passing to Api=====>$savedCookie");
    try {
      final response = await _dio
          .post(
            '/api/devices/trigger-switch',
            data: payload,
            options: Options(
              headers: {
                'Cookie': savedCookie,
              },
            ),
          )
          .timeout(const Duration(seconds: 5));
      debugPrint("Api Response=====> $response");
      debugPrint("Api ResponseData=====> ${response.data}");
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint("${e.response}");
        throw Exception('trigger-switch failed: ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('error: $e');
    }
  }

  Future<dynamic> deleteSwitch(Map<String, dynamic> payload) async {
    debugPrint("Payload Passing to Api=====> $payload");
    String? savedCookie = SharedPreferenceServices().getAuthCookie();
    debugPrint("Header Passing to Api=====>$savedCookie");
    try {
      final response = await _dio
          .delete(
            '/api/devices/delete',
            data: payload,
            options: Options(
              headers: {
                'Cookie': savedCookie,
              },
            ),
          )
          .timeout(const Duration(seconds: 5));
      debugPrint("Api Response=====> $response");
      debugPrint("Api ResponseData=====> ${response.data}");
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint("${e.response}");
        throw Exception('delete-switch failed: ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('error: $e');
    }
  }

  Future<dynamic> sendOtp(Map<String, dynamic> payload) async {
    debugPrint("Payload Passing to Api=====> $payload");
    debugPrint("Header Passing to Api=====>${_dio.options.headers}");
    try {
      final response = await _dio
          .post(
            '/api/auth/send-otp',
            data: payload,
          )
          .timeout(const Duration(seconds: 5));
      final setCookie = response.headers.map['set-cookie']?.first;
      if (setCookie != null) {
        authCookie = setCookie.split(';').first;
        debugPrint("Saved Cookie: $authCookie");
        await SharedPreferenceServices().saveOtpCookie(authCookie);
      }
      debugPrint("Api Response=====> $response");
      debugPrint("Api ResponseData=====> ${response.data}");
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Otp send failed: ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('error: $e');
    }
  }

  Future<dynamic> verifyOtp(Map<String, dynamic> payload) async {
    debugPrint("Payload Passing to Api=====> $payload");
    String? savedCookie = SharedPreferenceServices().getOtpCookie();
    debugPrint("Header Passing to Api=====>$savedCookie");

    try {
      final response = await _dio
          .post(
            '/api/auth/verify-otp',
            data: payload,
            options: Options(
              headers: {
                'Cookie': savedCookie,
              },
            ),
          )
          .timeout(const Duration(seconds: 5));
      final setCookie = response.headers.map['set-cookie']?.first;
      if (setCookie != null) {
        authCookie = setCookie.split(';').first;
        debugPrint("Saved Cookie: $authCookie");
        await SharedPreferenceServices().saveAuthCookie(authCookie);
      }
      debugPrint("Api Response=====> $response");
      debugPrint("Api ResponseData=====> ${response.data}");
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Otp verification failed: ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('error: $e');
    }
  }

  Future<dynamic> logout() async {
    debugPrint(">>>>>>>>>${_dio.options.headers}");
    try {
      final response = await _dio.post(
        '/api/auth/logout',
        data: {},
      ).timeout(const Duration(seconds: 5));
      debugPrint("Api Response=====> $response");
      debugPrint("Api ResponseData=====> ${response.data}");
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Logout failed: ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('error: $e');
    }
  }
}
