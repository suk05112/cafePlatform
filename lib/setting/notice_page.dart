import "package:flutter/material.dart";
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/api/notice_response.dart';
import 'package:intl/intl.dart';

class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  List<UserNotice> _notices = [];
  UserNotice? _selectedNotice;

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      await Api().setBaseClient(Api.BASE_URL);
      final response = await Api().client.getUserNotice();

      setState(() {
        _notices = response.notices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = '공지사항을 불러올 수 없습니다.\n${e.toString()}';
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy. MM. dd').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _showNoticeDetail(UserNotice notice) {
    setState(() {
      _selectedNotice = notice;
    });
  }

  void _backToList() {
    setState(() {
      _selectedNotice = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 상세 화면 표시
    if (_selectedNotice != null) {
      return WillPopScope(
        onWillPop: () async {
          _backToList();
          return false; // 뒤로가기 기본 동작 방지
        },
        child: Scaffold(
          appBar: const CommonAppBar(title: '공지사항'),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedNotice!.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _formatDate(_selectedNotice!.created_at),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 10),
                        Divider(
                            height: 1, thickness: 1, color: Colors.grey[200]),
                        SizedBox(height: 24),
                        Text(
                          _selectedNotice!.content,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 리스트 화면
    return Scaffold(
      appBar: const CommonAppBar(title: '공지사항'),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(ColorAssset.mainColor)))
            : _hasError
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            _errorMessage ?? '공지사항을 불러올 수 없습니다.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadNotices,
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
                  )
                : _notices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              '공지사항이 없습니다',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadNotices,
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: _notices.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey[200],
                          ),
                          itemBuilder: (context, index) {
                            final notice = _notices[index];
                            return InkWell(
                              onTap: () => _showNoticeDetail(notice),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notice.title,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            _formatDate(notice.created_at),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}
