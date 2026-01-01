import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cafeplatform/api/ApiClient.dart';
import 'package:cafeplatform/config/config.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

class Api {
  static final _singleton = Api._internal();

  factory Api() => _singleton;

  // User-Agent는 동적으로 추가되므로 초기화 시점에 설정
  late final Dio dio;
  late var client;

  Api._internal() {
    _initializeClients();
  }

  Future<void> _initializeClients() async {
    final headers = await _getHeaders();
    final options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      headers: headers,
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 5),
    );
    dio = Dio(options)..interceptors.add(CustomLogInterceptor());
    client = ApiClient(Dio(options)..interceptors.add(CustomLogInterceptor()));
  }

  static const String STAGING_URL = "https://www.502company.com/dev";
  static const String STAGING_URL_V2 = "http://18.221.2.135";
  static const String BASE_URL = "https://www.502company.com/dev";

  /// User-Agent를 생성하는 함수
  static Future<String> _getUserAgent() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final appName = packageInfo.appName;
      final appVersion = packageInfo.version;

      String platform;
      String osVersion = '';
      String deviceModel = '';

      final deviceInfoPlugin = DeviceInfoPlugin();

      if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        platform = 'iOS';
        osVersion = iosInfo.systemVersion;
        deviceModel = iosInfo.model;
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        platform = 'Android';
        osVersion = androidInfo.version.release;
        deviceModel = androidInfo.model;
      } else {
        platform = Platform.operatingSystem;
        osVersion = Platform.operatingSystemVersion;
      }

      // User-Agent 형식: AppName/Version (Platform; OS Version; Device Model)
      return '$appName/$appVersion ($platform; $osVersion; $deviceModel)';
    } catch (e) {
      // 에러 발생 시 기본값 반환
      print('User-Agent 생성 오류: $e');
      return 'Gifnut/1.0.0 (${Platform.operatingSystem})';
    }
  }

  /// 기본 헤더를 생성하는 함수 (User-Agent 포함)
  static Future<Map<String, String>> _getHeaders() async {
    final userAgent = await _getUserAgent();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'User-Agent': userAgent,
      // 'X-API-KEY': 'app-id=loplat-go-android,signature=d8d6513401f6714cc98b72bc5bc7e2bfcca13b4fe89b22183f470537e57c040c',
    };
  }

  /// V2, 이외의 baseURL 이 필요할때 사용한다.
  Future<ApiClient> setTempClient(String baseUrl) async {
    final headers = await _getHeaders();
    Dio dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: headers,
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 5),
      sendTimeout: Duration(seconds: 5),
    ))
      ..interceptors.add(CustomLogInterceptor());

    return ApiClient(dio, baseUrl: baseUrl);
  }

  /// 이 함수가 호출 된 이후,
  /// Api().client 의 baseURL 은 변경됩니다.
  // ApiClient setBaseClient(String baseUrl, [accessToken]) {
  Future<ApiClient> setBaseClient(String baseUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(); // Firebase ID Token
    final appCheck = await FirebaseAppCheck.instance.getToken();
    final baseHeaders = await _getHeaders();

    Dio dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        ...baseHeaders,
        'Authorization': 'Bearer $idToken',
        "X-Firebase-AppCheck": appCheck,
      },
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 5),
      sendTimeout: Duration(seconds: 5),
    ))
      ..interceptors.add(CustomLogInterceptor())
      ..interceptors.add(AuthInterceptor());

    dio.options.headers.forEach((k, v) => print('  $k: $v'));

    // CashPlaceClient 는 Abstract class 이기 때문에
    // baseUrl 변경은 생성 시에만 설정이 가능하다.
    //client = CashPlaceClient(dio, baseUrl: baseUrl);
    client = ApiClient(dio, baseUrl: baseUrl);

    return client;
  }

  void setAccessToken(String? accessToken) {
    setBaseClient(BASE_URL);
    // setBaseClient(STAGING_URL_V2, accessToken);
  }
}

class CustomLogInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // User-Agent가 없으면 동적으로 추가
    if (!options.headers.containsKey('User-Agent')) {
      final userAgent = await Api._getUserAgent();
      options.headers['User-Agent'] = userAgent;
    }
    print("base url ${options.baseUrl}");
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(response);
    print(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}, message[${err.response?.statusMessage}], [${err.response?.toString()}]',
    );
    super.onError(err, handler);
  }
}

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    print(['dio error interceptor']);
    if (err.response?.statusCode == 401) {
      print('[401 interceptor] at ${err.requestOptions.path}');

      print('path : ${err.requestOptions.path}');
      if (err.requestOptions.path == 'auth/refresh') {
        handler.next(err);
        return;
      }

      // String? refreshToken = await LoplatSecureStorage.read(LoplatSecureStorage.keyRefreshToken);

      // if (refreshToken == null) {
      //   print('[401 interceptor] refresh token is null');
      //   // TODO : 토큰이 없을 경우 => api를 콜한 위젯에서 로그인 페이지로 이동
      //   handler.next(err);
      // }

      // print('[401 interceptor] refresh token $refreshToken');

      // refresh access token
      try {
        print('[401 interceptor] call auth/refresh start');
        // HttpResponse<AuthRefreshResponse> authRefreshResponse = await Api().client.postAuthRefresh(AuthRefreshPost(refresh_token: refreshToken!));

        print('[401 interceptor] call auth/refresh success');

        // request 재요청
        final user = FirebaseAuth.instance.currentUser;
        final idToken = await user?.getIdToken(); // Firebase ID Token
        final appCheck = await FirebaseAppCheck.instance.getToken();

        // print("app check token ${appCheck}");

        RequestOptions requestOptions = err.requestOptions;
        final baseHeaders = await Api._getHeaders();
        Dio dio = Dio(BaseOptions(
          baseUrl: Api.STAGING_URL_V2,
          headers: {
            ...baseHeaders,
            'Authorization': 'Bearer $idToken',
            "X-Firebase-AppCheck": appCheck,
          },
        ));

        print('[401 interceptor] 재요청');

        handler.resolve(await dio.request(
          requestOptions.path,
          options: Options(method: requestOptions.method),
          cancelToken: requestOptions.cancelToken,
          onReceiveProgress: requestOptions.onReceiveProgress,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
        ));

/*
        if (authRefreshResponse.response.statusCode == 200) {
          print('[401 interceptor] call auth/refresh statuscode 200');

          String accessToken = authRefreshResponse.data.access_token;
          String refreshToken = authRefreshResponse.data.refresh_token;

          Api().setBaseClient(Api.STAGING_URL_V2, accessToken);
          await LoplatSecureStorage.write(
              LoplatSecureStorage.keyRefreshToken, refreshToken);
          await LoplatSecureStorage.write(
              LoplatSecureStorage.keyAccessToken, accessToken);

          // request 재요청
          RequestOptions requestOptions = err.requestOptions;
          Dio dio = Dio(BaseOptions(
            baseUrl: Api.STAGING_URL_V2,
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json; charset=UTF-8',
            },
          ));

          print('[401 interceptor] 재요청');

          handler.resolve(await dio.request(
            requestOptions.path,
            options: Options(method: requestOptions.method),
            cancelToken: requestOptions.cancelToken,
            onReceiveProgress: requestOptions.onReceiveProgress,
            data: requestOptions.data,
            queryParameters: requestOptions.queryParameters,
          ));
        } else {
          print(err);
          handler.next(err);
        }
        */
      } on DioException catch (e) {
        print('auth interceptor error');
        print(e);
        handler.next(err);
      }
    }

    handler.next(err);
  }
}
