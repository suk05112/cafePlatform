import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "약관 보기"),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          children: [
            _buildTermsItem(
              context,
              title: '서비스 이용약관',
              url: 'https://www.502company.com/term/user/service/',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TermsWebViewPage(
                      title: '서비스 이용약관',
                      url: 'https://www.502company.com/term/user/service/',
                    ),
                  ),
                );
              },
            ),
            Divider(height: 1, color: Colors.grey[200]),
            _buildTermsItem(
              context,
              title: '개인정보 처리방침',
              url: 'https://www.502company.com/term/user/privacy/',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TermsWebViewPage(
                      title: '개인정보 처리방침',
                      url: 'https://www.502company.com/term/user/privacy/',
                    ),
                  ),
                );
              },
            ),
            Divider(height: 1, color: Colors.grey[200]),
            _buildTermsItem(
              context,
              title: '마케팅 이용약관',
              url: 'https://www.502company.com/term/user/marketing/',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TermsWebViewPage(
                      title: '마케팅 이용약관',
                      url: 'https://www.502company.com/term/user/marketing/',
                    ),
                  ),
                );
              },
            ),
            Divider(height: 1, color: Colors.grey[200]),
            _buildTermsItem(
              context,
              title: '위치서비스 이용약관',
              url: 'https://www.502company.com/term/user/location-term',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TermsWebViewPage(
                      title: '위치서비스 이용약관',
                      url: 'https://www.502company.com/term/user/location-term',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsItem(
    BuildContext context, {
    required String title,
    required String url,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }
}

class TermsWebViewPage extends StatefulWidget {
  final String title;
  final String url;

  const TermsWebViewPage({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<TermsWebViewPage> createState() => _TermsWebViewPageState();
}

class _TermsWebViewPageState extends State<TermsWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  static int _viewIdCounter = 1;
  late final int _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = _viewIdCounter++;

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
              _errorMessage = null;
            });
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _hasError = false;
            });
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
              // 네트워크 오류인지 확인
              if (error.errorCode == -1009 ||
                  error.errorCode == -1001 ||
                  error.errorCode == -1004 ||
                  error.errorCode == -1005 ||
                  error.description.toLowerCase().contains('network') ||
                  error.description.toLowerCase().contains('internet') ||
                  error.description.toLowerCase().contains('connection')) {
                _errorMessage = '인터넷 연결을 확인해주세요.\n네트워크에 연결되어 있지 않습니다.';
              } else {
                _errorMessage = '페이지를 불러올 수 없습니다.\n${error.description}';
              }
            });
            debugPrint('''
              Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      );

    // WebView 캐시 삭제 및 설정
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      final androidController = controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
      // Android WebView 캐시 삭제 후 페이지 로드
      androidController.clearCache().then((_) {
        debugPrint('Android WebView 캐시 삭제 완료');
        // 캐시 삭제 후 페이지 로드
        controller.loadRequest(Uri.parse(widget.url));
      }).catchError((error) {
        debugPrint('캐시 삭제 오류: $error');
        // 오류 발생 시에도 페이지 로드
        controller.loadRequest(Uri.parse(widget.url));
      });
    } else {
      // iOS의 경우 캐시를 우회하기 위해 URL에 타임스탬프 추가
      final urlWithTimestamp = widget.url.contains('?')
          ? '${widget.url}&_t=${DateTime.now().millisecondsSinceEpoch}'
          : '${widget.url}?_t=${DateTime.now().millisecondsSinceEpoch}';
      controller.loadRequest(Uri.parse(urlWithTimestamp));
    }

    _controller = controller;
  }

  void _reloadPage() {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _isLoading = true;
    });
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: widget.title),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            if (!_hasError)
              SizedBox.expand(
                child: WebViewWidget(
                  controller: _controller,
                  key: ValueKey('terms_webview_$_viewId'),
                ),
              ),
            if (_hasError)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        _errorMessage ?? '페이지를 불러올 수 없습니다.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _reloadPage,
                        icon: Icon(Icons.refresh),
                        label: Text('다시 시도'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_isLoading && !_hasError)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
