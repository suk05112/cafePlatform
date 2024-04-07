import 'package:dio/dio.dart';
import 'package:my_app/api/ApiClient.dart';
import 'package:retrofit/dio.dart';

class Api {
  Api._internal();

  static final _singleton = Api._internal();

  factory Api() => _singleton;

  Dio dio = Dio(_options)..interceptors.add(CustomLogInterceptor());
  var client = ApiClient(Dio()..interceptors.add(CustomLogInterceptor()));

  static const String STAGING_URL = "http://3.23.128.179";
  static const String STAGING_URL_V2 = "http://3.23.128.179";
  static const String BASE_URL = "http://3.23.128.179";
  // static const String BASE_URL =
  //     "https://ot113tt778.execute-api.us-east-2.amazonaws.com/staging/";
  static final _options = BaseOptions(
      baseUrl: STAGING_URL_V2,
      headers: _headers,
      connectTimeout: 60000,
      receiveTimeout: 60000);
  static final _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    // 'X-API-KEY': 'app-id=loplat-go-android,signature=d8d6513401f6714cc98b72bc5bc7e2bfcca13b4fe89b22183f470537e57c040c',
  };

  /// V2, 이외의 baseURL 이 필요할때 사용한다.
  ApiClient setTempClient(String baseUrl) {
    Dio dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: _headers,
      connectTimeout: 60000,
      receiveTimeout: 60000,
      sendTimeout: 60000,
    ))
      ..interceptors.add(CustomLogInterceptor());

    return ApiClient(dio, baseUrl: baseUrl);
  }

  /// 이 함수가 호출 된 이후,
  /// Api().client 의 baseURL 은 변경됩니다.
  ApiClient setBaseClient(String baseUrl, [accessToken]) {
    Dio dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: accessToken != null
          ? {..._headers, 'Authorization': 'Bearer $accessToken'}
          : _headers,
      connectTimeout: 60000,
      receiveTimeout: 60000,
      sendTimeout: 60000,
    ))
      ..interceptors.add(CustomLogInterceptor())
      ..interceptors.add(AuthInterceptor());

    // CashPlaceClient 는 Abstract class 이기 때문에
    // baseUrl 변경은 생성 시에만 설정이 가능하다.
    //client = CashPlaceClient(dio, baseUrl: baseUrl);
    client = ApiClient(dio, baseUrl: baseUrl);

    return client;
  }

  void setAccessToken(String? accessToken) {
    setBaseClient(STAGING_URL_V2, accessToken);
  }
}

class CustomLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
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
  void onError(DioError err, ErrorInterceptorHandler handler) {
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
    DioError err,
    ErrorInterceptorHandler handler,
  ) async {
    /*
    print(['dio error interceptor']);
    if (err.response?.statusCode == 401) {
      print('[401 interceptor] at ${err.requestOptions.path}');

      print('path : ${err.requestOptions.path}');
      if (err.requestOptions.path == 'auth/refresh') {
        handler.next(err);
        return;
      }

      // String? refreshToken = await LoplatSecureStorage.read(LoplatSecureStorage.keyRefreshToken);

      if (refreshToken == null) {
        print('[401 interceptor] refresh token is null');
        // TODO : 토큰이 없을 경우 => api를 콜한 위젯에서 로그인 페이지로 이동
        handler.next(err);
      }

      print('[401 interceptor] refresh token $refreshToken');

      // refresh access token
      try {
        print('[401 interceptor] call auth/refresh start');
        // HttpResponse<AuthRefreshResponse> authRefreshResponse = await Api().client.postAuthRefresh(AuthRefreshPost(refresh_token: refreshToken!));

        print('[401 interceptor] call auth/refresh success');

        if (authRefreshResponse.response.statusCode == 200) {
          print('[401 interceptor] call auth/refresh statuscode 200');

          String accessToken = authRefreshResponse.data.access_token;
          String refreshToken = authRefreshResponse.data.refresh_token;

          Api().setBaseClient(Api.STAGING_URL_V2, accessToken);
          await LoplatSecureStorage.write(LoplatSecureStorage.keyRefreshToken, refreshToken);
          await LoplatSecureStorage.write(LoplatSecureStorage.keyAccessToken, accessToken);

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
      } on DioError catch (e) {
        print('auth interceptor error');
        print(e);
        handler.next(err);
      }
    }

    handler.next(err);
    */
  }
}
