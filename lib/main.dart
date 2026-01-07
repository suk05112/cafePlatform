import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:cafeplatform/Home.dart';
import 'package:cafeplatform/MenuForStore.dart';
import 'package:cafeplatform/SignIn/terms_agreement_page.dart';
import 'package:cafeplatform/api/API.dart';
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

// 백그라운드 메시지 핸들러 (top-level 함수여야 함)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('백그라운드 메시지 수신: ${message.messageId}');
  print('메시지 데이터: ${message.data}');
  if (message.notification != null) {
    print('알림 제목: ${message.notification?.title}');
    print('알림 내용: ${message.notification?.body}');
  }
}

// void main() => runApp(MyApp()); // 프로그램을 실행할 때 MyApp 부터 실행하겠어!

// void main() async {
final AppLinks _appLinks = AppLinks();
FutureOr<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 백그라운드 메시지 핸들러 등록 (Firebase 초기화 전에 등록해야 함)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Firebase가 이미 초기화되지 않은 경우에만 초기화
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // 이미 초기화된 경우 무시
    print("Firebase 이미 초기화됨 또는 초기화 오류: $e");
  }

  await _initialize();

  runApp(MyApp());
  // handleDeepLinks();
}

Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown, // 필요 없으면 제거
  ]);

  await NaverMapSdk.instance.initialize(
      clientId: 'ofzfofvuev',
      onAuthFailed: (ex) => log("********* 네이버맵 인증오류 : $ex *********"));

  // Firebase Crashlytics 초기화 및 에러 핸들러 설정
  try {
    // Crashlytics 수집 활성화/비활성화 설정
    // Debug 모드에서도 테스트를 위해 활성화 (필요시 false로 변경)
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    // Flutter 에러 핸들러 설정
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      // 디버그 모드에서는 원래 에러도 표시
      if (kDebugMode) {
        FlutterError.presentError(errorDetails);
      }
    };

    // 플랫폼 레벨 에러 핸들러 설정
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    print("✅ Firebase Crashlytics 초기화 완료");
  } catch (e) {
    print("❌ Firebase Crashlytics 에러 핸들러 설정 오류: $e");
  }

  // FCM 토큰 초기화 및 저장
  await _initializeFCM();

  getPermission();
  await Api().setBaseClient(Api.BASE_URL);
}

void handleDeepLink(Uri uri) async {
  print('Deep link received: $uri');
  print('  - scheme: ${uri.scheme}');
  print('  - host: ${uri.host}');
  print('  - path: ${uri.path}');
  print('  - queryParameters: ${uri.queryParameters}');

  // gifnut:// 스킴 또는 https://www.502company.com/gift 경로 처리
  if (uri.scheme == 'gifnut' ||
      (uri.scheme == 'https' &&
          uri.host == 'www.502company.com' &&
          uri.path == '/gift')) {
    // gifnut://gift?gifticon_id=... 또는 gifnut://share?type=store&id=... 형식 처리
    if (uri.host == 'gift' || uri.path == '/gift') {
      // 기프티콘 선물받기 처리
      final gifticonId = uri.queryParameters['gifticon_id'];
      print('기프티콘 선물받기 - gifticon_id: $gifticonId');

      if (gifticonId != null && gifticonId.isNotEmpty) {
        final gifticonIdInt = int.tryParse(gifticonId);
        if (gifticonIdInt != null) {
          // Get.context를 통해 Provider에 접근
          final context = Get.context;
          if (context != null) {
            try {
              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);

              if (userProvider.isLoggedIn) {
                // 로그인 되어있으면 기프티콘 등록 페이지로 이동
                print("로그인 상태: 기프티콘 등록 페이지로 이동");
                // 현재 화면을 모두 제거하고 새로운 페이지로 이동 (앱이 실행 중일 때)
                Get.offAll(
                    () => RegisterGifticonPage(gifticon_id: gifticonIdInt));
              } else {
                // 로그인 안되어있으면 딥링크 정보를 저장하고 로그인 페이지로 이동
                print("비로그인 상태: 딥링크 정보 저장 후 로그인 페이지로 이동");
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('pending_gifticon_id', gifticonIdInt);
                Get.offAll(() => LoginPage());
              }
            } catch (e) {
              print("Provider 접근 오류: $e");
              // 오류 발생 시 딥링크 정보 저장 후 로그인 페이지로 이동
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('pending_gifticon_id', gifticonIdInt);
              Get.offAll(() => LoginPage());
            }
          } else {
            // context가 없으면 딥링크 정보를 저장하고 로그인 페이지로 이동
            print("Context가 없음: 딥링크 정보 저장 후 로그인 페이지로 이동");
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('pending_gifticon_id', gifticonIdInt);
            // context가 없으면 잠시 대기 후 다시 시도
            await Future.delayed(const Duration(milliseconds: 500));
            final retryContext = Get.context;
            if (retryContext != null) {
              Get.offAll(() => LoginPage());
            }
          }
          return;
        }
      }
    } else if (uri.host == 'share') {
      // gifnut://share?type=store&id=... 형식 처리
      final type = uri.queryParameters['type'];
      final id = uri.queryParameters['id'];
      print('공유 링크 - type: $type, id: $id');

      if (type == 'store' && id != null) {
        final storeId = int.tryParse(id);
        if (storeId != null) {
          // 매장 상세 페이지로 이동
          print("매장 상세 페이지로 이동: store_id=$storeId");
          // TODO: StorePage로 이동하는 로직 추가 필요
          // Get.offAll(() => StorePage(storeId: storeId, storeName: ''));
          return;
        }
      }
    }
  }

  // 기존 로직 (gifticon_id가 없는 경우)
  final query = uri.queryParameters['query'];
  if (query != null && query == 'one') {
    print("기존 로직: query=one");
    Get.offAll(() => CafeList());
    // TODO: '/friends' 라우트가 등록되어 있지 않으므로 주석 처리
    // Get.toNamed('/friends'); // 친구 목록 페이지로 이동
  } else if (query != null && query == 'two') {
    print("기존 로직: query=two");
    // TODO: '/main' 라우트가 등록되어 있지 않으므로 주석 처리
    // Get.offAllNamed('/main'); // 메인 페이지로 이동
    Get.offAll(() => SplashScreen()); // SplashScreen으로 이동
  } else {
    print("기존 로직: 기본 페이지");
    // GetX 라우팅에 '/signin'이 등록되어 있지 않으므로 위젯 직접 사용
    Get.offAll(() => LoginPage()); // 로그인 페이지로 이동
  }
}

/*
Future<void> handleDeepLinks() async {
  // 앱이 처음 실행될 때 딥링크 처리
  try {
    final initialLink = await getInitialLink();
    print('Initial deep link: $initialLink');
    if (initialLink != null) {
      final uri = Uri.parse(initialLink);
      handleDeepLink(uri); // 딥링크 처리 함수 호출
    }
  } on PlatformException {
    // 예외 처리 (특히 앱이 백그라운드에서 실행될 때 발생할 수 있음)
    print("Error getting initial deep link");
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
    final messaging = FirebaseMessaging.instance;

    // 알림 권한 요청 (iOS)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('FCM 알림 권한 상태: ${settings.authorizationStatus}');

    // 포그라운드 메시지 핸들러
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('포그라운드 메시지 수신!');
      print('메시지 데이터: ${message.data}');

      if (message.notification != null) {
        print('알림 제목: ${message.notification?.title}');
        print('알림 내용: ${message.notification?.body}');
      }
    });

    // 앱이 종료된 상태에서 알림을 탭했을 때 처리
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('알림 탭으로 앱 열림');
      print('메시지 데이터: ${message.data}');
      if (message.notification != null) {
        print('알림 제목: ${message.notification?.title}');
        print('알림 내용: ${message.notification?.body}');
      }
    });

    // 앱이 종료된 상태에서 알림을 탭하여 앱이 시작된 경우 처리
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      print('초기 메시지로 앱 시작');
      print('메시지 데이터: ${initialMessage.data}');
      if (initialMessage.notification != null) {
        print('알림 제목: ${initialMessage.notification?.title}');
        print('알림 내용: ${initialMessage.notification?.body}');
      }
    }

    // FCM 토큰 가져오기
    String? token = await messaging.getToken();

    if (token != null) {
      print('FCM 토큰: $token');

      // SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      print('FCM 토큰 저장 완료');
    } else {
      print('FCM 토큰을 가져올 수 없습니다.');
    }

    // 토큰 갱신 리스너
    messaging.onTokenRefresh.listen((newToken) {
      print('FCM 토큰 갱신: $newToken');
      _saveFCMToken(newToken);
    });
  } catch (e) {
    print('FCM 초기화 오류: $e');
  }
}

Future<void> _saveFCMToken(String token) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
    print('FCM 토큰 저장 완료: $token');
  } catch (e) {
    print('FCM 토큰 저장 오류: $e');
  }
}

getPermission() async {
  print("위치권한 요청");

  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  var requestStatus = await Permission.location.request();
  var status = await Permission.location.status;
  // var status = await Permission.locationWhenInUse.status;
  if (status.isGranted) {
    print('허락됨');
  } else if (status.isDenied) {
    print('거절됨');
    Permission.contacts.request(); // 현재 거절된 상태니 팝업창 띄워달라는 코드
  }
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          handleDeepLink(initialUri);
        });
      }

      // ✅ 앱 실행 중 / 백그라운드 복귀
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
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
      print('Initial deep link: $initialLink');
      if (initialLink != null) {
        final uri = Uri.parse(initialLink);
        // WidgetsBinding.instance.addPostFrameCallback을 사용하여 context가 준비된 후 처리
        WidgetsBinding.instance.addPostFrameCallback((_) {
          handleDeepLink(uri);
        });
      }
    } on PlatformException {
      print("Error getting initial deep link");
    }

    // 앱이 실행 중일 때 딥링크를 수신하기 위한 리스너 설정
    _linkSubscription = linkStream.listen(
      (String? link) {
        if (link != null) {
          print('Deep link received while app is running: $link');
          final uri = Uri.parse(link);
          // context가 준비된 후 처리
          WidgetsBinding.instance.addPostFrameCallback((_) {
            handleDeepLink(uri);
          });
        }
      },
      onError: (err) {
        print('Deep link error: $err');
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
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return NetworkChecker(
            child: GetMaterialApp(
              title: "MyApp",
              debugShowCheckedModeBanner: false,
              theme: ThemeData(primarySwatch: Colors.blue),
              home: SplashScreen(),
            ),
          );
        },
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
  late int _selectedIndex; // 처음에 나올 화면 지정

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
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
      body: Center(
        child: _pages[_selectedIndex], // 페이지와 연결
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
    // state 갱신
    setState(() {
      _selectedIndex = index; // index는 item 순서로 0, 1, 2로 구성
    });
  }
}
