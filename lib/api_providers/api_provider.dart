import 'dart:convert';

import 'package:bbts/api_providers/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class ApiProvider {
  final Dio _dio = DioClient().dio;

  Future<dynamic> login(Map<String, dynamic> payload) async {
    debugPrint("Payload Passing to Api=====> $payload");
    debugPrint(">>>>>>>>>${_dio.options.headers}");
    debugPrint("Header Passing to Api=====>${_dio.options.headers}");
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: payload,
      );
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
    try {
      final response = await _dio.post(
        '/api/devices/add',
        data: payload,
      );
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
    try {
      final response = await _dio.get(
        '/api/devices/list',
        data: {},
      );
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
    try {
      final response = await _dio.post(
        '/api/devices/trigger-switch',
        data: payload,
      );
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
    try {
      final response = await _dio.delete(
        '/api/devices/delete',
        data: payload,
      );
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
      final response = await _dio.post(
        '/api/auth/send-otp',
        data: payload,
      );
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
    try {
      final response = await _dio.post(
        '/api/auth/verify-otp',
        data: payload,
      );

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
      );
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

  Future<dynamic> getSwitchStatus(Map<String, dynamic> payload) async {
    debugPrint("payload Passing to Api=====>$payload");
    try {
      final response = await _dio.post(
        '/api/devices/details',
        options: Options(validateStatus: (status) => true),
        data: payload,
      );
      debugPrint("Get Switch Status Api Response=====> $response");

      debugPrint("Get Switch Status Api ResponseData=====> ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("======$e");
      throw Exception(e.toString());
    }
  }

  Future<dynamic> addGroup(Map<String, dynamic> payload) async {
    debugPrint("payload Passing to Api=====>$payload");
    try {
      final response = await _dio.post(
        '/api/v1/group/add',
        options: Options(validateStatus: (status) => true),
        data: payload,
      );
      debugPrint("Get Switch Status Api Response=====> $response");

      debugPrint("Get Switch Status Api ResponseData=====> ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("======$e");
      throw Exception(e.toString());
    }
  }

  Future<dynamic> getGroupList() async {
    try {
      final response = await _dio.get(
        '/api/v1/group/list',
        data: {},
      );
      debugPrint("Api Response=====> $response");

      debugPrint("Api ResponseData=====> ${response.data}");
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('getGroupList: ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<dynamic> deleteGroupData(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.delete(
        '/api/v1/group/delete',
        queryParameters: payload,
      );
      debugPrint("Api Response=====> $response");

      debugPrint("Api ResponseData=====> ${response.data}");
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('getGroupList: ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
