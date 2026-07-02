import 'package:flutter/material.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:intl/intl.dart';

class NoticeDetailPage extends StatefulWidget {
  final int noticeId;
  final String title;
  final String createdAt;

  const NoticeDetailPage({
    super.key,
    required this.noticeId,
    required this.title,
    required this.createdAt,
  });

  @override
  State<NoticeDetailPage> createState() => _NoticeDetailPageState();
}

class _NoticeDetailPageState extends State<NoticeDetailPage> {
  bool _isLoading = true;
  String? _content;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      await Api().setBaseClient(Api.BASE_URL);
      final response = await Api().client.getUserNoticeDetail(widget.noticeId);
      setState(() {
        _content = response.data.content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _content = null;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy.MM.dd').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '공지사항'),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(ColorAssset.mainColor),
                ),
              )
            : _content == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          '공지사항을 불러올 수 없습니다.',
                          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            setState(() => _isLoading = true);
                            _loadDetail();
                          },
                          child: Text(
                            '다시 시도',
                            style: TextStyle(color: ColorAssset.mainColor),
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(widget.createdAt),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Divider(height: 1, thickness: 1, color: Colors.grey[200]),
                        const SizedBox(height: 24),
                        Text(
                          _content!,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.7,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
