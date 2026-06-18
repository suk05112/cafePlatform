import 'dart:async';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

enum PayletterResult { success, cancel, fail }

class PayletterResultData {
  final PayletterResult result;
  final String? orderNo;
  final String? tid;
  final String? message;

  PayletterResultData({
    required this.result,
    this.orderNo,
    this.tid,
    this.message,
  });
}

class PayletterWebViewPage extends StatefulWidget {
  const PayletterWebViewPage({super.key, required this.mobileUrl});

  final String mobileUrl;

  @override
  State<PayletterWebViewPage> createState() => _PayletterWebViewPageState();
}

class _PayletterWebViewPageState extends State<PayletterWebViewPage> {
  late final WebViewController _controller;
  late final StreamSubscription<Uri> _deepLinkSub;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
    _listenDeepLink();
  }

  void _initWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            debugPrint('[Payletter] navigating to: $url');

            final uri = Uri.tryParse(url);
            if (uri == null) return NavigationDecision.prevent;

            // gifnut:// 결제 결과 딥링크 — 웹뷰에서 직접 처리
            if (uri.scheme == 'gifnut' && uri.host == 'payment') {
              _handleGifnutPaymentDeepLink(uri);
              return NavigationDecision.prevent;
            }

            // 페이레터 return URL — 백엔드가 gifnut://payment/result 로 302 리다이렉트함
            // iOS WKWebView는 302를 onNavigationRequest 없이 자동으로 따라가므로 여기서 가로챔
            if ((uri.scheme == 'http' || uri.scheme == 'https') &&
                (uri.host.contains('gifnut.com') ||
                    uri.host.contains('502company.com')) &&
                uri.path.endsWith('/order/payment/return')) {
              _handlePayletterReturnUrl(uri);
              return NavigationDecision.prevent;
            }

            // http/https는 웹뷰에서 처리
            if (uri.scheme == 'http' || uri.scheme == 'https') {
              return NavigationDecision.navigate;
            }

            // 그 외 앱 스킴은 즉시 prevent 반환 후 비동기로 외부 앱 실행
            // (async로 만들면 iOS WKWebView가 반환 전에 네비게이션을 시작해 -1002 에러 발생)
            _launchExternalApp(url, uri);
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.mobileUrl));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  void _listenDeepLink() {
    _deepLinkSub = AppLinks().uriLinkStream.listen((uri) {
      debugPrint('[Payletter] deep link received: $uri');

      if (uri.scheme != 'gifnut') return;

      // gifnut://payment/result
      if (uri.host == 'payment' && uri.path == '/result') {
        final code = uri.queryParameters['code'];
        final orderNo = uri.queryParameters['order_no'];
        final tid = uri.queryParameters['tid'];
        final message = uri.queryParameters['message'];

        final isSuccess = code == null || code == '0';
        _popWithResult(PayletterResultData(
          result: isSuccess ? PayletterResult.success : PayletterResult.fail,
          orderNo: orderNo,
          tid: tid,
          message: message,
        ));
        return;
      }

      // gifnut://payment/cancel
      if (uri.host == 'payment' && uri.path == '/cancel') {
        final orderNo = uri.queryParameters['order_no'];
        _popWithResult(PayletterResultData(
          result: PayletterResult.cancel,
          orderNo: orderNo,
        ));
      }
    });
  }

  void _handlePayletterReturnUrl(Uri uri) {
    debugPrint('[Payletter] return URL intercepted: $uri');
    final params = uri.queryParameters;
    final code = params['code'];
    final orderNo = params['order_no'];
    final tid = params['tid'];
    final message = params['message'];

    // 백엔드가 이 URL을 gifnut://payment/result?{params} 로 302 포워딩하므로
    // 동일한 기준으로 처리: code가 없거나 '0'이면 성공
    final isSuccess = code == null || code == '0';
    _popWithResult(PayletterResultData(
      result: isSuccess ? PayletterResult.success : PayletterResult.fail,
      orderNo: orderNo,
      tid: tid,
      message: message,
    ));
  }

  void _handleGifnutPaymentDeepLink(Uri uri) {
    debugPrint('[Payletter] gifnut payment deep link: $uri');

    if (uri.path == '/result') {
      final code = uri.queryParameters['code'];
      final isSuccess = code == null || code == '0';
      _popWithResult(PayletterResultData(
        result: isSuccess ? PayletterResult.success : PayletterResult.fail,
        orderNo: uri.queryParameters['order_no'],
        tid: uri.queryParameters['tid'],
        message: uri.queryParameters['message'],
      ));
    } else if (uri.path == '/cancel') {
      _popWithResult(PayletterResultData(
        result: PayletterResult.cancel,
        orderNo: uri.queryParameters['order_no'],
      ));
    }
  }

  void _launchExternalApp(String url, Uri uri) async {
    if (uri.scheme == 'intent') {
      // Android intent:// — fallback URL로 시도
      final fallback = _extractIntentFallbackUrl(url);
      final target = fallback != null ? Uri.parse(fallback) : uri;
      try {
        await launchUrl(target, mode: LaunchMode.externalApplication);
      } catch (_) {}
    } else {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  // Android intent:// URL에서 S.browser_fallback_url 추출
  String? _extractIntentFallbackUrl(String intentUrl) {
    final match = RegExp(r'S\.browser_fallback_url=([^;]+)').firstMatch(intentUrl);
    if (match == null) return null;
    return Uri.decodeFull(match.group(1)!);
  }

  void _popWithResult(PayletterResultData data) {
    if (!mounted) return;
    Navigator.of(context).pop(data);
  }

  @override
  void dispose() {
    _deepLinkSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: '결제'),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Center(child: CircularProgressIndicator(color: ColorAssset.mainColor)),
          ],
        ),
      ),
    );
  }
}
