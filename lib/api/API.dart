import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cafeplatform/api/ApiClient.dart';
import 'package:cafeplatform/config/config.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart' hide Response;

class Api {
  static final _singleton = Api._internal();

  factory Api() => _singleton;

  // User-Agent는 동적으로 추가되므로 초기화 시점에 설정
  late final Dio dio;
  late var client;

  // App Check Token 캐싱 (중복 요청 방지)
  static String? _cachedAppCheckToken;
  static DateTime? _cachedTokenTime;
  static const Duration _tokenCacheDuration =
      Duration(minutes: 5); // 토큰 캐시 유지 시간
  static bool _isGettingToken = false; // 토큰 가져오기 중 플래그

  Api._internal() {
    _initializeClients();
  }

  Future<void> _initializeClients() async {
    final headers = await _getHeaders();
    final options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      headers: headers,
      connectTimeout: Duration(seconds: 15),
      receiveTimeout: Duration(seconds: 15),
    );
    dio = Dio(options)..interceptors.add(CustomLogInterceptor());
    client = ApiClient(Dio(options)..interceptors.add(CustomLogInterceptor()));
  }

  static const String STAGING_URL = "https://www.502company.com/dev";
  static const String STAGING_URL_V2 = "http://18.221.2.135";

  // Flavor에 따른 BASE_URL 반환 (dev: /dev, prod: /prod)
  static String get BASE_URL => AppConfig.baseUrl;

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

  /// App Check Token을 가져오는 공통 함수 (재시도 및 캐싱 포함)
  static Future<String?> _getAppCheckToken({bool forceRefresh = false}) async {
    // 캐시된 토큰이 있고 아직 유효하면 반환
    if (!forceRefresh &&
        _cachedAppCheckToken != null &&
        _cachedTokenTime != null &&
        DateTime.now().difference(_cachedTokenTime!) < _tokenCacheDuration) {
      return _cachedAppCheckToken;
    }

    // 이미 토큰을 가져오는 중이면 대기
    if (_isGettingToken) {
      // 최대 3초 대기
      for (int i = 0; i < 30; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!_isGettingToken) {
          return _cachedAppCheckToken;
        }
      }
      return _cachedAppCheckToken; // 타임아웃 시 캐시된 토큰 반환
    }

    _isGettingToken = true;
    try {
      // 첫 번째 시도
      try {
        final tokenResult = await FirebaseAppCheck.instance
            .getToken()
            .timeout(const Duration(seconds: 12));
        if (tokenResult != null) {
          // getToken() 반환값 처리 (String 또는 AppCheckToken 객체)
          String? tokenString;
          try {
            // AppCheckToken 객체인 경우 token 프로퍼티 접근 시도
            tokenString = (tokenResult as dynamic).token as String?;
          } catch (_) {
            // String이거나 다른 타입인 경우
            tokenString = tokenResult.toString();
          }

          if (tokenString != null && tokenString.isNotEmpty) {
            _cachedAppCheckToken = tokenString;
            _cachedTokenTime = DateTime.now();
            return _cachedAppCheckToken;
          }
        }
      } on TimeoutException catch (_) {
        print('⚠️ Firebase App Check getToken 타임아웃');
        if (_cachedAppCheckToken != null) {
          return _cachedAppCheckToken;
        }
        return null;
      } catch (e) {
        final errorMessage = e.toString().toLowerCase();

        // "Too many attempts" 에러인 경우 일정 시간 대기 후 재시도
        if (errorMessage.contains('too many attempts') ||
            errorMessage.contains('too_many_attempts')) {
          print('⚠️ App Check Token: Too many attempts, 5초 대기 후 재시도...');
          await Future.delayed(const Duration(seconds: 5));

          // 두 번째 시도
          try {
            final tokenResult = await FirebaseAppCheck.instance
                .getToken()
                .timeout(const Duration(seconds: 12));
            if (tokenResult != null) {
              // getToken() 반환값 처리 (String 또는 AppCheckToken 객체)
              String? tokenString;
              try {
                // AppCheckToken 객체인 경우 token 프로퍼티 접근 시도
                tokenString = (tokenResult as dynamic).token as String?;
              } catch (_) {
                // String이거나 다른 타입인 경우
                tokenString = tokenResult.toString();
              }

              if (tokenString != null && tokenString.isNotEmpty) {
                _cachedAppCheckToken = tokenString;
                _cachedTokenTime = DateTime.now();
                return _cachedAppCheckToken;
              }
            }
          } catch (e2) {
            print('⚠️ Firebase App Check Token 가져오기 실패 (재시도 후): $e2');
            // 재시도 후에도 실패하면 캐시된 토큰이 있으면 사용
            if (_cachedAppCheckToken != null) {
              print('⚠️ 캐시된 App Check Token 사용');
              return _cachedAppCheckToken;
            }
            return null;
          }
        } else {
          // 다른 에러인 경우
          print('⚠️ Firebase App Check Token 가져오기 실패: $e');
          // 캐시된 토큰이 있으면 사용
          if (_cachedAppCheckToken != null) {
            print('⚠️ 캐시된 App Check Token 사용');
            return _cachedAppCheckToken;
          }
          return null;
        }
      }
    } finally {
      _isGettingToken = false;
    }

    return _cachedAppCheckToken;
  }

  /// V2, 이외의 baseURL 이 필요할때 사용한다.
  Future<ApiClient> setTempClient(String baseUrl) async {
    final headers = await _getHeaders();
    Dio dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: headers,
      connectTimeout: Duration(seconds: 15),
      receiveTimeout: Duration(seconds: 15),
      sendTimeout: Duration(seconds: 15),
    ))
      ..interceptors.add(CustomLogInterceptor());

    return ApiClient(dio, baseUrl: baseUrl);
  }

  static Future<String?> _idTokenForSetBase(User? user, bool quickStart) async {
    if (user == null) return null;
    if (quickStart) {
      try {
        return await user
            .getIdToken()
            .timeout(const Duration(seconds: 6));
      } catch (_) {
        return null;
      }
    }
    return user.getIdToken();
  }

  static Future<String?> _appCheckForSetBase(bool quickStart) async {
    if (quickStart) {
      try {
        return await _getAppCheckToken()
            .timeout(const Duration(seconds: 5));
      } catch (_) {
        return null;
      }
    }
    return _getAppCheckToken();
  }

  /// 이 함수가 호출 된 이후,
  /// Api().client 의 baseURL 은 변경됩니다.
  ///
  /// [quickStart]: 스플래시·첫 진입 시 App Check/토큰을 짧게만 기다리고 병렬로 처리해
  /// 화면 전환이 수십 초 걸리는 것을 줄입니다. 로그인 성공 후 등에는 생략(기본 false).
  Future<ApiClient> setBaseClient(String baseUrl, {bool quickStart = false}) async {
    final user = FirebaseAuth.instance.currentUser;

    final tokens = await Future.wait<String?>([
      _idTokenForSetBase(user, quickStart),
      _appCheckForSetBase(quickStart),
    ]);
    final idToken = tokens[0];
    final appCheckToken = tokens[1];

    final baseHeaders = await _getHeaders();

    final headers = <String, dynamic>{
      ...baseHeaders,
      if (idToken != null) 'Authorization': 'Bearer $idToken',
      if (appCheckToken != null && appCheckToken.isNotEmpty)
        "X-Firebase-AppCheck": appCheckToken,
    };

    Dio dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: headers,
      connectTimeout: Duration(seconds: 15),
      receiveTimeout: Duration(seconds: 15),
      sendTimeout: Duration(seconds: 15),
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

  void _showErrorSnackbar(String message) {
    if (Get.context == null) return;
    Get.snackbar(
      '오류',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    print(['dio error interceptor']);
    print('❌ Error: ${err.type} [${err.type}]: ${err.message}');

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
        _showErrorSnackbar('인터넷 연결을 확인해 주세요.');
        break;
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        _showErrorSnackbar('네트워크가 불안정합니다. 잠시 후 다시 시도해 주세요.');
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        if (statusCode >= 500) {
          _showErrorSnackbar('서버에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.');
        }
        // 4xx는 아래 401 처리 포함, 각 화면에서 개별 처리
        break;
      case DioExceptionType.unknown:
        if (err.error is SocketException) {
          _showErrorSnackbar('인터넷 연결을 확인해 주세요.');
        } else {
          _showErrorSnackbar('알 수 없는 오류가 발생했습니다.');
        }
        break;
      default:
        break;
    }

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

        // App Check 토큰 가져오기 (공통 함수 사용, 401 에러 시에는 캐시 무시)
        // 캐시 무시를 위해 forceRefresh를 true로 설정하되, 실제로는 캐시를 사용하지 않도록
        final appCheckToken = await Api._getAppCheckToken(forceRefresh: true);

        RequestOptions requestOptions = err.requestOptions;
        final baseHeaders = await Api._getHeaders();
        final headers = <String, dynamic>{
          ...baseHeaders,
          if (idToken != null) 'Authorization': 'Bearer $idToken',
          if (appCheckToken != null && appCheckToken.isNotEmpty)
            "X-Firebase-AppCheck": appCheckToken,
        };
        Dio dio = Dio(BaseOptions(
          baseUrl: requestOptions.baseUrl, // 원래 baseUrl 사용
          headers: headers,
          connectTimeout: Duration(seconds: 15),
          receiveTimeout: Duration(seconds: 15),
          sendTimeout: Duration(seconds: 15),
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
