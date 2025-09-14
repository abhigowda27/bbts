import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

/// More examples see https://github.com/cfug/dio/blob/main/example
class ApiConnect {
  static Future<dynamic> hitApiPost(
      String url, Map<String, dynamic> params) async {
    debugPrint("Urls passing $url");
    debugPrint("Payload passing $params");
    final dio = Dio();
    final response = await dio.post(
      url,
      data: (params),
    );
    debugPrint("Api Response $response");
    debugPrint(response.data.toString());
    return response.data;
  }

  static Future<String> hitApiGet(url) async {
    debugPrint("Urls passing $url");
    final dio = Dio();
    final response = await dio.get(url);
    return response.data;
  }
}
