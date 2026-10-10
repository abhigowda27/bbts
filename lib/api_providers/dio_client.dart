import 'package:bbts/api_providers/auth_interceptor.dart';
import 'package:bbts/controllers/shared_preference.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

import '../common/globals.dart' as globals;
import '../constants.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();

  factory DioClient() => _instance;

  DioClient._internal();

  late final Dio dio;
  late final PersistCookieJar cookieJar;

  Future<void> init() async {
    final appDir = await getApplicationSupportDirectory();

    final cookiePath = '${appDir.path}/.cookies';

    cookieJar = PersistCookieJar(
      storage: FileStorage(cookiePath),
    );

    dio = Dio(
      BaseOptions(
        baseUrl: Constants.apiEndPoint,
        headers: {
          'Content-Type': 'application/json',
          'deviceid': globals.deviceId ?? '',
        },
        connectTimeout: const Duration(minutes: 1),
        receiveTimeout: const Duration(minutes: 1),
      ),
    );

    dio.interceptors.add(
      CookieManager(cookieJar),
    );

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        preferences: SharedPreferenceServices(),
      ),
    );
  }

  Future<void> clearCookies() async {
    await cookieJar.deleteAll();
  }
}
