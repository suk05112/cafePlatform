import 'package:flutter/material.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/model/Inquiry.dart';
import 'package:cafeplatform/model/user.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:cafeplatform/widget/network_aware_widget.dart';
import 'package:provider/provider.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';

class InquiryPage extends StatefulWidget {
  const InquiryPage({super.key});

  @override
  State<InquiryPage> createState() => _InquiryPageState();
}

class _InquiryPageState extends State<InquiryPage>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  Future<InquiryListResponse?>? futureInquiryList;
  Set<int> expandedItems = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging && _tabController.index == 1) {
      // "나의 문의내역" 탭(index 1)으로 변경되었을 때 API 호출
      fetchInquiry();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void fetchInquiry() {
    User? user = Provider.of<UserProvider>(context, listen: false).user;
    setState(() {
      futureInquiryList = Api().client.getInquiry(user?.user_id ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CommonAppBar(title: "문의하기"),
        backgroundColor: Colors.white,
        body: SafeArea(
            child: NetworkAwareWidget(
          onRetry: fetchInquiry,
          child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getTabBarWidget(),
                        SizedBox(height: 12),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            physics: NeverScrollableScrollPhysics(),
                            children: <Widget>[InquiryForm(), InquiryList()],
                          ),
                        )
                      ]))),
        )));
  }

  Widget getTabBarWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 50,
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          dividerColor: Colors.transparent,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.symmetric(vertical: 4),
          tabs: const [
            Tab(
              child: Text(
                "문의하기",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            Tab(
              child: Text(
                "나의 문의내역",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget InquiryForm() {
    User? user = Provider.of<UserProvider>(context, listen: false).user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목 입력
                Text(
                  "제목",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: titleController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: '제목을 입력해주세요',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ColorAssset.mainColor, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  validator: (value) {
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // 내용 입력
                Text(
                  "내용",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  height: 300,
                  child: TextFormField(
                    controller: contentController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    textAlignVertical: TextAlignVertical.top,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      hintText: '내용을 입력해주세요',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ColorAssset.mainColor, width: 2),
                      ),
                      contentPadding: EdgeInsets.all(16),
                    ),
                    validator: (value) {
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // 제출 버튼 (맨 아래 고정)
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              foregroundColor: Colors.white,
              backgroundColor: (titleController.text.trim().isNotEmpty &&
                      contentController.text.trim().isNotEmpty)
                  ? ColorAssset.mainColor
                  : Colors.grey[300]!,
              elevation: 0,
            ),
            onPressed: (titleController.text.trim().isNotEmpty &&
                    contentController.text.trim().isNotEmpty)
                ? () {
                    var inquiry = Inquiry(
                        title: titleController.text,
                        content: contentController.text);
                    Api().client.subjectInquiry(user?.user_id ?? 0, inquiry);
                    _showInquirySuccessDialog();

                    fetchInquiry();
                  }
                : null,
            child: Text(
              '문의하기 제출',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget InquiryList() {
    if (futureInquiryList == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              "문의 내역을 불러오려면 탭을 클릭해주세요",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return FutureBuilder<InquiryListResponse?>(
        future: futureInquiryList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(),
            ));
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Error: ${snapshot.error}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            List<InquiryResponse> inquiryList = snapshot.data!.inquiryResponse;

            if (inquiryList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      "문의 내역이 없습니다",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    fetchInquiry();
                  });
                },
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: inquiryList.length,
                  itemBuilder: (context, index) {
                    bool isExpanded = expandedItems.contains(index);
                    InquiryResponse inquiry = inquiryList[index];
                    bool hasResponse = inquiry.response?.isNotEmpty == true;

                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  expandedItems.remove(index);
                                } else {
                                  expandedItems.add(index);
                                }
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    inquiry.status == "pending"
                                                        ? Colors.orange[50]
                                                        : Colors.green[50],
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                inquiry.status == "pending"
                                                    ? "답변대기"
                                                    : "답변완료",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: inquiry.status ==
                                                          "pending"
                                                      ? Colors.orange[700]
                                                      : Colors.green[700],
                                                ),
                                              ),
                                            ),
                                            Spacer(),
                                            Icon(
                                              isExpanded
                                                  ? Icons.expand_less
                                                  : Icons.expand_more,
                                              color: Colors.grey[400],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          inquiry.title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "${inquiry.inquiry_created.year}.${inquiry.inquiry_created.month.toString().padLeft(2, '0')}.${inquiry.inquiry_created.day.toString().padLeft(2, '0')}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isExpanded) ...[
                            Divider(height: 1, indent: 16, endIndent: 16),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "문의 내용",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    inquiry.content,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 1.5,
                                    ),
                                  ),
                                  if (hasResponse) ...[
                                    SizedBox(height: 16),
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.reply,
                                                size: 16,
                                                color: Colors.blue[700],
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                "답변",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blue[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            inquiry.response!,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ] else ...[
                                    SizedBox(height: 16),
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            "답변 대기 중입니다",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ));
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 12),
                  Text(
                    "문의내역 읽어오기 실패",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }

  Widget showContents(content) {
    if (content == null || content == "") {
      return const Text("답변 대기 중입니다");
    }
    return Text(content);
  }

  void _showInquirySuccessDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 성공 아이콘
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 40,
                    color: Colors.green[600],
                  ),
                ),
                SizedBox(height: 20),
                // 제목
                Text(
                  "등록완료",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                // 내용
                Text(
                  "문의하기 등록이 완료되었습니다.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                // 확인 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: Colors.white,
                      backgroundColor: ColorAssset.mainColor,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    onPressed: () {
                      titleController.text = "";
                      contentController.text = "";
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
