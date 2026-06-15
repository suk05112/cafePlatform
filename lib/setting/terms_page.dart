import 'package:flutter/material.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  void _openTerms(BuildContext context, String title, String termType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TermsWebViewPage(title: title, termType: termType),
      ),
    );
  }

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
              termType: 'SERVICE',
            ),
            Divider(height: 1, color: Colors.grey[200]),
            _buildTermsItem(
              context,
              title: '개인정보 처리방침',
              termType: 'PRIVACY',
            ),
            Divider(height: 1, color: Colors.grey[200]),
            _buildTermsItem(
              context,
              title: '마케팅 이용약관',
              termType: 'MARKETING',
            ),
            Divider(height: 1, color: Colors.grey[200]),
            _buildTermsItem(
              context,
              title: '위치서비스 이용약관',
              termType: 'LOCATION',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsItem(
    BuildContext context, {
    required String title,
    required String termType,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: () => _openTerms(context, title, termType),
    );
  }
}

class TermsWebViewPage extends StatefulWidget {
  final String title;
  final String termType;

  const TermsWebViewPage({
    super.key,
    required this.title,
    required this.termType,
  });

  @override
  State<TermsWebViewPage> createState() => _TermsWebViewPageState();
}

class _TermsWebViewPageState extends State<TermsWebViewPage> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    try {
      final response = await Api().client.getTermsContent(widget.termType);
      if (!mounted) return;
      await _webViewController.loadHtmlString(response.content);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '약관을 불러오는데 실패했습니다.\n잠시 후 다시 시도해주세요.';
        _isLoading = false;
      });
      return;
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: widget.title),
      backgroundColor: Colors.white,
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xff6A6A6A)),
          ),
        ),
      );
    }
    return Stack(
      children: [
        WebViewWidget(controller: _webViewController),
        if (_isLoading)
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ColorAssset.mainColor),
            ),
          ),
      ],
    );
  }
}
