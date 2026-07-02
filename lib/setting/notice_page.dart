import 'package:flutter/material.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/api/notice_response.dart';
import 'package:cafeplatform/setting/notice_detail_page.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  bool _isLoading = true;
  bool _hasError = false;
  List<NoticeListItem> _notices = [];

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      await Api().setBaseClient(Api.BASE_URL);
      final response = await Api().client.getUserNotice(page: 1, limit: 20);
      setState(() {
        _notices = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
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
            : _hasError
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
                          onPressed: _loadNotices,
                          child: Text(
                            '다시 시도',
                            style: TextStyle(color: ColorAssset.mainColor),
                          ),
                        ),
                      ],
                    ),
                  )
                : _notices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              '공지사항이 없습니다.',
                              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadNotices,
                        color: ColorAssset.mainColor,
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: _notices.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey[200],
                          ),
                          itemBuilder: (context, index) {
                            final notice = _notices[index];
                            return InkWell(
                              onTap: () => Get.to(
                                () => NoticeDetailPage(
                                  noticeId: notice.id,
                                  title: notice.title,
                                  createdAt: notice.created_at,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _formatDate(notice.created_at),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            notice.title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
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
