import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/api/user_response.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:cafeplatform/Home.dart';
import 'package:cafeplatform/MenuForStore.dart';
import 'package:cafeplatform/SignIn/terms_agreement_page.dart';
import 'package:cafeplatform/cafeList/cafe_list_map_view.dart';
import 'package:cafeplatform/cafeList/cafe_list_page.dart';
import 'package:cafeplatform/SignIn/login_page.dart';
import 'package:cafeplatform/splash_screen.dart';
import 'package:cafeplatform/setting/myPage.dart';
import 'package:cafeplatform/GiftBox.dart';
import 'package:cafeplatform/provider/menu_provider.dart';
import 'package:cafeplatform/provider/order_provider.dart';
import 'package:cafeplatform/provider/store_provider.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:cafeplatform/setting/setting_page.dart';
import 'package:cafeplatform/Payment/register_gifticon_page.dart';
import 'package:cafeplatform/gifticon_page.dart';
import 'package:cafeplatform/tosspayments/widget_home.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_links/app_links.dart';
import 'package:cafeplatform/widget/network_checker.dart';
import 'package:cafeplatform/api/popup_response.dart';
import 'package:cafeplatform/widget/popup_carousel_dialog.dart';
import 'package:cafeplatform/utils/fcm_token_util.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:cafeplatform/utils/meta_analytics_service.dart';

const _kNotificationChannelId = 'default_channel';
const _kNotificationChannelName = '기프넛 알림';

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

Future<void> _initLocalNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings();
  await _localNotifications.initialize(
    const InitializationSettings(android: androidInit, iOS: iosInit),
  );
  await _localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          _kNotificationChannelId,
          _kNotificationChannelName,
          importance: Importance.high,
        ),
      );
}

void _showLocalNotification(RemoteMessage message) {
  final notification = message.notification;
  final title = notification?.title ?? message.data['title'];
  final body = notification?.body ?? message.data['body'];
  if (title == null && body == null) return;

  _localNotifications.show(
    message.hashCode,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        _kNotificationChannelId,
        _kNotificationChannelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
  );
}

// 백그라운드 메시지 핸들러 (top-level 함수여야 함)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  DartPluginRegistrant.ensureInitialized();
  await _initLocalNotifications();
  _showLocalNotification(message);
}

// void main() => runApp(MyApp()); // 프로그램을 실행할 때 MyApp 부터 실행하겠어!

// void main() async {
final AppLinks _appLinks = AppLinks();
FutureOr<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 백그라운드 메시지 핸들러 등록 (Firebase 초기화 전에 등록해야 함)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // MyApp을 즉시 띄우고, 무거운 초기화는 _StartupShell에서 비동기로 진행 (릴리스 스플래시 정지 완화)
  runApp(const _StartupShell());
  // handleDeepLinks();
}

/// 네이버맵 — UI를 막지 않음 ([release 스플래시 정지](https://medium.com/@chetan.akarte/flutter-app-freezes-on-the-splash-screen-in-release-mode-e15a6045a189) 대응)
Future<void> _initNaverMapSdk() async {
  try {
    await NaverMapSdk.instance
        .initialize(
          clientId: 'ofzfofvuev',
          onAuthFailed: (ex) =>
              log("********* 네이버맵 인증오류 : $ex *********"),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () =>
              log('네이버맵 SDK 초기화 타임아웃 — 지도 기능에 제한이 있을 수 있음'),
        );
  } catch (e, st) {
    log('네이버맵 SDK 초기화 오류: $e', stackTrace: st);
  }
}

Future<void> _initialize() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  if (!kDebugMode) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                '일시적인 오류가 발생했습니다.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              SizedBox(height: 8),
              Text(
                '잠시 후 다시 시도해 주세요.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    };
  }

  try {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      if (kDebugMode) {
        FlutterError.presentError(errorDetails);
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

  } catch (e) {
  }

  // setBaseClient는 스플래시·로그인에서 호출 (여기서 await 하면 App Check·토큰과 겹쳐 수십 초 대기 유발)

  // FCM·네이버맵은 백그라운드에서 진행 (스플래시/첫 화면을 막지 않음)
  unawaited(_initializeFCM());
  unawaited(_initNaverMapSdk());
  unawaited(FacebookAppEvents().setAutoLogAppEventsEnabled(true));
  unawaited(MetaAnalyticsService.instance.logAppLaunch());
}

void handleDeepLink(Uri uri) async {

  // gifnut://payment/result 또는 gifnut://payment/cancel — PayletterWebViewPage가 직접 처리
  if (uri.scheme == 'gifnut' && uri.host == 'payment') {
    return;
  }

  // 카카오 OAuth 콜백 URL은 무시 (카카오 SDK가 자체적으로 처리)
  // kakaoc...://oauth 또는 kakao...://oauth 형식의 URL은 카카오 로그인 OAuth 콜백
  if (uri.host == 'oauth' &&
      (uri.scheme.startsWith('kakaoc') || uri.scheme.startsWith('kakao'))) {
    return;
  }

  // 카카오 링크 처리 (kakaoc...://kakaolink 또는 kakao...://kakaolink?gifticon_id=...)
  // Flutter 앱이 완전히 초기화될 때까지 대기 (최대 3초)
  bool isKakaoLink = (uri.scheme.startsWith('kakaoc') || uri.scheme.startsWith('kakao')) && uri.host == 'kakaolink';

  if (isKakaoLink) {
    int retryCount = 0;
    const maxRetries = 30;
    while (Get.context == null && retryCount < maxRetries) {
      await Future.delayed(const Duration(milliseconds: 100));
      retryCount++;
    }
  }

  // gifnut:// 스킴 또는 https://www.502company.com/gift 경로 처리
  bool isGifnutLink = uri.scheme == 'gifnut' ||
      (uri.scheme == 'https' &&
          uri.host == 'www.502company.com' &&
          uri.path == '/gift');

  if (isKakaoLink || isGifnutLink) {
    // 기프티콘 선물받기 처리
    final gifticonId = uri.queryParameters['gifticon_id'];

    if (gifticonId != null && gifticonId.isNotEmpty) {
      final gifticonIdInt = int.tryParse(gifticonId);
      if (gifticonIdInt != null) {
        // context가 준비될 때까지 추가 대기 (필요시)
        var context = Get.context;
        if (context == null) {
          await Future.delayed(const Duration(milliseconds: 500));
          context = Get.context;
        }

        if (context != null) {
          try {
            final userProvider =
                Provider.of<UserProvider>(context, listen: false);

            // UserProvider에서 로그인 상태를 다시 확인 (비동기 로드 완료 대기)
            await userProvider.fetchUser();

            // 로그인 상태 확인 (재확인)
            if (userProvider.isLoggedIn && userProvider.user != null) {
              // 로그인 되어있으면 기프티콘 등록 페이지로 이동
              // 약간의 지연을 추가하여 Flutter가 완전히 준비되도록 함
              await Future.delayed(const Duration(milliseconds: 300));
              Get.offAll(
                  () => RegisterGifticonPage(gifticon_id: gifticonIdInt));
            } else {
              // 로그인 안되어있으면 딥링크 정보를 저장하고 로그인 페이지로 이동
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('pending_gifticon_id', gifticonIdInt);
              await Future.delayed(const Duration(milliseconds: 300));
              Get.offAll(() => LoginPage());
            }
          } catch (e) {
            // 오류 발생 시 딥링크 정보 저장 후 로그인 페이지로 이동
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('pending_gifticon_id', gifticonIdInt);
            await Future.delayed(const Duration(milliseconds: 300));
            Get.offAll(() => LoginPage());
          }
        } else {
          // context가 여전히 없으면 딥링크 정보를 저장하고 로그인 페이지로 이동
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('pending_gifticon_id', gifticonIdInt);
          await Future.delayed(const Duration(milliseconds: 300));
          Get.offAll(() => LoginPage());
        }
        return;
      }
    } else {
      // gifticon_id가 없으면 매장 리스트 페이지로 이동
      await Future.delayed(const Duration(milliseconds: 300));
      Get.offAll(() => TabPage(initialIndex: 0));
      return;
    }
  }

  // gifnut://share?type=store&id=... 형식 처리
  if (uri.scheme == 'gifnut' && uri.host == 'share') {
    final type = uri.queryParameters['type'];
    final id = uri.queryParameters['id'];

    if (type == 'store' && id != null) {
      final storeId = int.tryParse(id);
      if (storeId != null) {
        // 매장 상세 페이지로 이동
        // TODO: StorePage로 이동하는 로직 추가 필요
        // Get.offAll(() => StorePage(storeId: storeId, storeName: ''));
        return;
      }
    }
  }

  // 기존 로직 (gifticon_id가 없는 경우)
  // 카카오 OAuth 콜백 등은 이미 위에서 처리했으므로 여기서는 추가 처리 불필요
  final query = uri.queryParameters['query'];
  if (query != null && query == 'one') {
    Get.offAll(() => CafeList());
    // TODO: '/friends' 라우트가 등록되어 있지 않으므로 주석 처리
    // Get.toNamed('/friends'); // 친구 목록 페이지로 이동
  } else if (query != null && query == 'two') {
    // TODO: '/main' 라우트가 등록되어 있지 않으므로 주석 처리
    // Get.offAllNamed('/main'); // 메인 페이지로 이동
    Get.offAll(() => SplashScreen()); // SplashScreen으로 이동
  } else {
    // 알 수 없는 딥링크인 경우만 처리 (카카오 OAuth는 이미 필터링됨)
    // 현재 로그인 중인 경우에는 네비게이션하지 않음
    // Get.offAll(() => LoginPage()); // 주석 처리 - 로그인 플로우 방해 방지
  }
}

/*
Future<void> handleDeepLinks() async {
  // 앱이 처음 실행될 때 딥링크 처리
  try {
    final initialLink = await getInitialLink();
    if (initialLink != null) {
      final uri = Uri.parse(initialLink);
      handleDeepLink(uri); // 딥링크 처리 함수 호출
    }
  } on PlatformException {
    // 예외 처리 (특히 앱이 백그라운드에서 실행될 때 발생할 수 있음)
  }

  // 딥링크를 수신하기 위한 리스너 설정
  linkStream.listen((String? link) {
    if (link != null) {
      final uri = Uri.parse(link);
      handleDeepLink(uri); // 딥링크 처리 함수 호출
    }
  });
}*/

Future<void> _initializeFCM() async {
  try {
    await _initLocalNotifications();

    final messaging = FirebaseMessaging.instance;

    // iOS 포그라운드에서도 알림 배너/소리/배지 표시
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 포그라운드 메시지 핸들러
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // 앱이 종료된 상태에서 알림을 탭했을 때 처리
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification != null) {
      }
    });

    // 앱이 종료된 상태에서 알림을 탭하여 앱이 시작된 경우 처리
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      if (initialMessage.notification != null) {
      }
    }

    // FCM 토큰: 권한이 이미 결정된 경우에만 요청 (notDetermined면 홈에서 권한 요청 후 토큰 갱신)
    final settings = await messaging.getNotificationSettings();
    if (settings.authorizationStatus != AuthorizationStatus.notDetermined) {
      final token = await fetchFcmTokenRespectingIosApns();
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
      }
    }

    // 토큰 갱신 리스너
    messaging.onTokenRefresh.listen((newToken) {
      _saveFCMToken(newToken);
    });
  } catch (e) {
  }
}

Future<void> _saveFCMToken(String token) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  } catch (e) {
  }
}


/// 첫 프레임에서 곧바로 [MyApp]을 그린 뒤, 무거운 초기화는 백그라운드에서 수행한다.
/// (스플래시/런치스크린에서 멈춤 — [Medium](https://medium.com/@chetan.akarte/flutter-app-freezes-on-the-splash-screen-in-release-mode-e15a6045a189))
class _StartupShell extends StatefulWidget {
  const _StartupShell();

  @override
  State<_StartupShell> createState() => _StartupShellState();
}

class _StartupShellState extends State<_StartupShell> {
  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  @override
  Widget build(BuildContext context) => const MyApp();
}

// StatelessWidget은 변화지 않는 화면을 작업할 때 사용.
// 변화는 화면을 작업 하고싶을 경우에는 StatefulWidget을 사용.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri?>? _linkSubscription;

  // MaterialApp = 앱으로서 기능을 할 수 있도록 도와주는 뼈대
  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    try {
      // ✅ 앱 완전 종료 상태에서 실행된 딥링크
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        // Flutter가 완전히 초기화될 때까지 대기
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // 첫 프레임이 렌더링된 후 약간의 지연을 추가
          await Future.delayed(const Duration(milliseconds: 500));
          handleDeepLink(initialUri);
        });
      }

      // ✅ 앱 실행 중 / 백그라운드 복귀
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await Future.delayed(const Duration(milliseconds: 300));
            handleDeepLink(uri);
          });
        },
        onError: (err) {
          debugPrint('Deep link error: $err');
        },
      );
    } catch (e) {
      debugPrint('Deep link init error: $e');
    }
  }

/*
  Future<void> _initDeepLinks() async {
    // 앱이 처음 실행될 때 딥링크 처리
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        final uri = Uri.parse(initialLink);
        // WidgetsBinding.instance.addPostFrameCallback을 사용하여 context가 준비된 후 처리
        WidgetsBinding.instance.addPostFrameCallback((_) {
          handleDeepLink(uri);
        });
      }
    } on PlatformException {
    }

    // 앱이 실행 중일 때 딥링크를 수신하기 위한 리스너 설정
    _linkSubscription = linkStream.listen(
      (String? link) {
        if (link != null) {
          final uri = Uri.parse(link);
          // context가 준비된 후 처리
          WidgetsBinding.instance.addPostFrameCallback((_) {
            handleDeepLink(uri);
          });
        }
      },
      onError: (err) {
      },
    ) as StreamSubscription<String?>?;
  }
  */

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return MaterialApp() -> Material 디자인 테마를 사용
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => StoreProvider()),
        ChangeNotifierProvider(create: (context) => MenuProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: NetworkChecker(
        child: GetMaterialApp(
          title: "MyApp",
          debugShowCheckedModeBanner: false,
          theme: ThemeData(primarySwatch: Colors.blue),
          home: SplashScreen(),
        ),
      ),
      /*
        child: GetMaterialApp(
          title: "MyApp", // 앱 이름
          debugShowCheckedModeBanner: false, // 타이틀 바 우측 띠 제거

          // 앱의 기본적인 테마를 지정
          theme: ThemeData(
            primarySwatch: Colors.blue, // priamrySwatch 기본적인 앱의 색상을 지정
          ),

          home: TabPage(), // 앱이 실행될 때 표시할 화면의 함수를 호출
        )
        */
    );
  }
}

// 앱이 실행 될때 표시할 화면의 함수
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  // scaffold = 구성된 앱에서 디자인적인 부분을 도와주는 뼈대

  // 화면 구성
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 앱의 body 부분
      body: Center(
        child: TabPage(),
      ),
    );
  }
}

// Bottom Navigation Bar
// 동적으로 화면을 변화하므로 StatefulWdiget 사용
class TabPage extends StatefulWidget {
  final int initialIndex;

  const TabPage({super.key, this.initialIndex = 0});

  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ATT는 앱이 active 상태여야 팝업이 뜨므로 팝업 다이얼로그보다 먼저,
      // 짧은 지연 후 요청 (지연·순서가 어긋나면 iOS가 조용히 무시함)
      await _requestPermissionsAndShowPrompts();
      await _showPopupsIfAny();
    });
  }

  Future<void> _showPopupsIfAny() async {
    if (!mounted) return;
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.user_id;
      final isLoggedIn = userId != null;

      // 비로그인 유저: 로컬에 오늘 하루 숨기기 여부 확인
      if (!isLoggedIn) {
        final prefs = await SharedPreferences.getInstance();
        final hiddenDate = prefs.getString('popup_hidden_date');
        final today = DateTime.now();
        final todayStr = '${today.year}-${today.month}-${today.day}';
        if (hiddenDate == todayStr) return;
      }

      final response = await Api().client.getPopups(userId: userId);
      final popups = response.data;
      if (popups.isEmpty || !mounted) return;

      popups.sort((PopupItem a, PopupItem b) => a.displayOrder.compareTo(b.displayOrder));

      final nav = Navigator.of(context);
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => PopupCarouselDialog(
          popups: popups,
          onHideToday: () async {
            nav.pop();
            if (isLoggedIn) {
              try {
                await Api().client.hidePopups(userId!);
              } catch (_) {}
            } else {
              final prefs = await SharedPreferences.getInstance();
              final today = DateTime.now();
              final todayStr = '${today.year}-${today.month}-${today.day}';
              await prefs.setString('popup_hidden_date', todayStr);
            }
          },
          onClose: nav.pop,
        ),
      );
    } catch (_) {}
  }

  Future<void> _requestPermissionsAndShowPrompts() async {
    if (!mounted) return;

    // 1. iOS ATT 광고 추적 권한 요청 (1회)
    if (Platform.isIOS) {
      var trackingStatus = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (trackingStatus == TrackingStatus.notDetermined) {
        // 앱이 포그라운드 active 상태가 된 뒤 요청해야 팝업이 뜸
        await Future.delayed(const Duration(milliseconds: 500));
        trackingStatus =
            await AppTrackingTransparency.requestTrackingAuthorization();
      }
      // ATT 동의 결과를 Meta SDK에 전달 (미전달 시 이벤트 전송 보류됨)
      await FacebookAppEvents().setAdvertiserTracking(
        enabled: trackingStatus == TrackingStatus.authorized,
      );
    }

    if (!mounted) return;

    // 3. 알림 시스템 권한 요청 (1회) + 결과를 service_push_enabled로 저장
    final notificationSettings = await FirebaseMessaging.instance.getNotificationSettings();
    if (notificationSettings.authorizationStatus == AuthorizationStatus.notDetermined) {
      final result = await FirebaseMessaging.instance.requestPermission(
        alert: true, badge: true, sound: true,
      );
      final granted =
          result.authorizationStatus == AuthorizationStatus.authorized ||
          result.authorizationStatus == AuthorizationStatus.provisional;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('service_push_enabled', granted);
      if (granted) {
        final token = await fetchFcmTokenRespectingIosApns();
        if (token != null) {
          await prefs.setString('fcm_token', token);
        }
      }
    }

    if (!mounted) return;

    // 4. 위치 시스템 권한 요청 (1회)
    final locationStatus = await Permission.location.status;
    if (locationStatus == PermissionStatus.denied) {
      await Permission.location.request();
    }

    if (!mounted) return;

    // 5. 이벤트·할인 바텀시트 (1회)
    final prefs = await SharedPreferences.getInstance();
    final notificationPromptShown = prefs.getBool('notification_prompt_shown') ?? false;
    if (!notificationPromptShown && mounted) {
      await _showNotificationPermissionSheet();
    }
  }

  // Future<void> _showLocationPermissionSheet() async {
  //   if (!mounted) return;
  //   await showModalBottomSheet(
  //     context: context,
  //     isDismissible: false,
  //     enableDrag: false,
  //     backgroundColor: Colors.white,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (ctx) => _LocationPermissionSheet(
  //       onAllow: () async {
  //         Navigator.pop(ctx);
  //         final prefs = await SharedPreferences.getInstance();
  //         await prefs.setBool('location_prompt_shown', true);
  //         await Permission.location.request();
  //       },
  //       onLater: () async {
  //         Navigator.pop(ctx);
  //         final prefs = await SharedPreferences.getInstance();
  //         await prefs.setBool('location_prompt_shown', true);
  //       },
  //     ),
  //   );
  // }

  Future<void> _showNotificationPermissionSheet() async {
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _NotificationPermissionSheet(
        onAllow: () async {
          Navigator.pop(ctx);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('notification_prompt_shown', true);
          await prefs.setBool('marketing_push_enabled', true);
          if (mounted) await _syncNotificationToServer();
        },
        onLater: () async {
          Navigator.pop(ctx);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('notification_prompt_shown', true);
          await prefs.setBool('marketing_push_enabled', false);
        },
      ),
    );
  }

  Future<void> _syncNotificationToServer() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      if (user == null) return;

      final prefs = await SharedPreferences.getInstance();
      final fcmToken = prefs.getString('fcm_token');
      if (fcmToken == null || fcmToken.isEmpty) return;

      // 서비스 푸시: 시스템 알림 권한 실제 상태 기준
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      final allowServicePush =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      await prefs.setBool('service_push_enabled', allowServicePush);

      final allowMarketingPush = prefs.getBool('marketing_push_enabled') ?? false;

      await Api().client.registerPushToken(
        user.user_id,
        PushTokenRequest(
          fcmToken: fcmToken,
          deviceType: Platform.isIOS ? 'ios' : 'android',
          allowServicePush: allowServicePush,
          allowMarketingPush: allowMarketingPush,
        ),
      );
    } catch (_) {}
  }

  // 이동할 페이지
  final List _pages = [
    /*Home(), */
    CafeList(), // 매장보기 (index 0)
    GiftBox(),
    // WidgetHome(), // 선물함 (index 1)
    // CafeList(), // mapview (index 2) - 나중에 맵뷰로 변경 가능
    SettingPage() // 더보기 (index 3)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages.map((p) => p as Widget).toList(),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType
            .fixed, // bottomNavigationBar item이 4개 이상일 경우
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex, // 현재 선택된 index
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[500],
        backgroundColor: Colors.white,
        // unselectedLabelStyle: TextStyle(color: Colors.grey.shade300),

        // BottomNavigationBarItem 위젯
        items: const <BottomNavigationBarItem>[
          // BottomNavigationBarItem(icon: Icon(Icons.home), label: "home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "매장보기"),
          BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard), label: "선물함"),
          // BottomNavigationBarItem(icon: Icon(Icons.search), label: "mapview"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "더보기"),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

// class _LocationPermissionSheet extends StatelessWidget {
//   final VoidCallback onAllow;
//   final VoidCallback onLater;
//
//   const _LocationPermissionSheet({
//     required this.onAllow,
//     required this.onLater,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Text(
//             '내 주변 매장을 찾아드릴게요',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             '현재 위치를 기반으로\n가까운 매장을 바로 확인할 수 있어요.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey.shade600,
//               height: 1.6,
//             ),
//           ),
//           const SizedBox(height: 28),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                     side: BorderSide(color: Colors.grey.shade300),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                   ),
//                   onPressed: onLater,
//                   child: const Text(
//                     '다음에 하기',
//                     style: TextStyle(
//                       fontSize: 15,
//                       color: Colors.black54,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                     backgroundColor: Colors.black,
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                   ),
//                   onPressed: onAllow,
//                   child: const Text(
//                     '위치 허용',
//                     style: TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

class _NotificationPermissionSheet extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onLater;

  const _NotificationPermissionSheet({
    required this.onAllow,
    required this.onLater,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '이벤트·할인 소식을 받아보세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '최신 이벤트, 할인 정보를 놓치지 마세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  onPressed: onLater,
                  child: const Text(
                    '다음에 하기',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  onPressed: onAllow,
                  child: const Text(
                    '알림 켜기',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
