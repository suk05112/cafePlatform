import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:cafeplatform/Extension/datetime_extension.dart';
import 'package:cafeplatform/Payment/GifticonInfo.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/model/gifticon.dart';
import 'package:cafeplatform/model/user.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cafeplatform/order/order_detail_page.dart';
import 'package:cafeplatform/order/receiver_refund_request_page.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cafeplatform/main.dart';

class GifticonPage extends StatefulWidget {
  const GifticonPage({super.key, required this.gifticon_id, this.fromKakao = false});

  final int gifticon_id;
  final bool fromKakao;
  @override
  State<GifticonPage> createState() => _GifticonPageState();

  static Future<Gifticon?> fetchGifticon(int gifticonId) async {
    try {
      // if (kDebugMode) {
      //   var gifticon = Gifticon(
      //       name: "사용된 기프티콘",
      //       status: "USED",
      //       store_name: "store_name",
      //       sender: "sender",
      //       description: "description",
      //       validity: DateTime(2025, 4, 1));
      //   return gifticon;
      // } else {
      await Api().setBaseClient(Api.BASE_URL);
      var response = await Api().client.getGifticon(gifticonId);
      var gifticon = response.gifticon;
      return gifticon;
      // }
    } catch (error) {
      return null;
    }
  }
}

class _GifticonPageState extends State<GifticonPage>
    with TickerProviderStateMixin {
  late bool showFront;
  late Future<Gifticon?> futureGifticon;
  late TabController _tabController;
  bool _didUseGifticon = false;

  @override
  void initState() {
    super.initState();

    showFront = true;
    futureGifticon =
        GifticonPage.fetchGifticon(widget.gifticon_id); // Proper initialization
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _didUseGifticon);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 44,
          title: const Text(
            "선물함",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.white,
          actions: widget.fromKakao
              ? [
                  IconButton(
                    icon: const Icon(Icons.home_outlined, color: Colors.black),
                    onPressed: () => Get.offAll(() => const TabPage(initialIndex: 1)),
                  ),
                ]
              : null,
        ),
        body: SafeArea(
            child: FutureBuilder<Gifticon?>(
                future: futureGifticon,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: ColorAssset.mainColor));
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.grey[400]),
                          SizedBox(height: 12),
                          Text(
                            "Error: ${snapshot.error}",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasData) {
                    Gifticon gifticon = snapshot.data!;
                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(height: 16),
                                  showSender(gifticon),
                                  Stack(alignment: Alignment.center, children: [
                                    Container(
                                      width: 200,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child:
                                            _buildMenuImage(gifticon.menu_url),
                                      ),
                                    ),
                                    usedOverlay(gifticon),
                                  ]),
                                  SizedBox(height: 16),
                                  Text(
                                    gifticon.store_name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    gifticon.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  if (gifticon.sender.isNotEmpty) ...[
                                    SizedBox(height: 6),
                                    gifticon.type == 1
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.person_outline,
                                                  size: 14,
                                                  color: Colors.grey[500]),
                                              SizedBox(width: 4),
                                              Text(
                                                'From ${gifticon.sender}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              )
                                            ],
                                          )
                                        : SizedBox(),
                                  ],
                                  SizedBox(height: 20),
                                  getTabBarWidget(),
                                  SizedBox(height: 12),
                                  selectedTabIndex == 0
                                      ? gifticonInfo(gifticon)
                                      : getDetailInfo(gifticon.store_name),
                                  SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // 하단 고정 버튼
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, -2),
                              ),
                            ],
                          ),
                          child: useButton(gifticon),
                        ),
                      ],
                    );
                  } else {
                    return Center(
                      child: Text(
                        "기프티콘 읽어오기 실패",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }
                }))),
      );
  }

  Widget showSender(gifticon) {
    if (gifticon.type == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.card_giftcard, size: 18, color: Colors.grey[700]),
                SizedBox(width: 8),
                Text(
                  'From ${gifticon.sender}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (gifticon.msg != null && gifticon.msg!.isNotEmpty) ...[
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Text(
                "${gifticon.msg}",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ],
          SizedBox(height: 8),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  int selectedTabIndex = 0;

  Widget getTabBarWidget2() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: Text("기본 정보"),
          selected: selectedTabIndex == 0,
          onSelected: (_) {
            setState(() {
              selectedTabIndex = 0;
            });
          },
        ),
        SizedBox(width: 10),
        ChoiceChip(
          label: Text("상세 정보"),
          selected: selectedTabIndex == 1,
          onSelected: (_) {
            setState(() {
              selectedTabIndex = 1;
            });
          },
        ),
      ],
    );
  }

  Widget getTabBarWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
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
                offset: Offset(0, 2),
              ),
            ],
          ),
          dividerColor: Colors.transparent,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          onTap: (index) {
            setState(() {
              selectedTabIndex = index;
            });
          },
          tabs: const [
            Tab(
              child: Text(
                "선물정보",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Tab(
              child: Text(
                "상세정보",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget gifticonInfo(Gifticon gifticon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              gifticonInfoRow('유효기간', '${gifticon.validity?.toDateString}'),
              gifticonInfoRow('쿠폰번호', gifticon.gift_code ?? ""),
              // gifticonInfoRow(
              // '선물주문일', '${gifticon.created_time?.toDateTimeString}'),
              gifticonInfoRow('쿠폰상태',
                  gifticonStatus(gifticon.status ?? "", gifticon.validity)),
              gifticonInfoRow('교환처', gifticon.store_address ?? '정보 없음'),
            ],
          ),
        ),
        SizedBox(height: 16),
        // 유의사항 섹션
        _buildPrecautionsSection(),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.map, size: 20, color: Colors.black87),
              SizedBox(width: 8),
              Text(
                '교환처 지도로보기',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        NaverMapWidget(
          latitude: gifticon.store_lat,
          longitude: gifticon.store_lng,
        ),
      ],
    );
  }

  Widget _buildPrecautionsSection() {
    final precautions = [
      '해당 상품권의 경우 잔액 환불 불가합니다.',
      '해당 상품권은 잔액관리 기능을 제공하지 않습니다.',
      '모바일 상품권은 구매 시 현금영수증이 발행되지 않으며, 발행 여부는 실제 사용처에 문의 부탁 드립니다.',
      '한시적으로 제공되는 무료 상품권 및 프로모션 연계 상품의 경우 유효기간 연장 및 환불이 불가합니다.',
      '교환권은 사용처 매장의 재고 상황에 따라 동일 상품으로 교환이 어려울 수 있습니다.',
      '일부 상품의 경우 각 매장별 금액이 상이할 수 있으며, 일부 매장에서는 추가 금액 결제가 필요할 수 있습니다.',
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Colors.orange[700],
                ),
                SizedBox(width: 6),
                Text(
                  '유의사항',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          ...precautions.map((precaution) => Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 2, right: 8),
                      child: Text(
                        '•',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        precaution,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget gifticonInfoRow(title, value) {
    return Column(children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text(
                '$title',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '$value',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
      Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey[200],
        indent: 16,
        endIndent: 16,
      ),
    ]);
  }

  String gifticonStatus(String status, validity) {
    if (validity!.isBefore(DateTime.now())) {
      return "기간만료";
    } else if (status == 'UNUSED') {
      return "사용가능";
    } else if (status == 'USED') {
      return "사용완료";
    } else if (status == 'EXPIRED') {
      return "기간만료";
    } else if (status == 'CANCELED') {
      return "취소됨";
    } else {
      return "사용 불가능";
    }
  }

  bool _canRequestReceiverRefund(gifticon) {
    if (gifticon.status != 'UNUSED') return false;
    if (gifticon.validity != null && gifticon.validity!.isBefore(DateTime.now())) {
      return false;
    }
    final refundDeadline = gifticon.refundDeadline;
    if (refundDeadline == null) return false;
    return !DateTime.now().isBefore(refundDeadline);
  }

  Widget refundRequestButton(gifticon) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        onPressed: () async {
          final requested = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ReceiverRefundRequestPage(orderId: gifticon.order_id),
            ),
          );
          if (requested == true && mounted) {
            _didUseGifticon = true;
            Provider.of<UserProvider>(context, listen: false).invalidateGifticonCache();
            Navigator.pop(context, true);
          }
        },
        child: Text(
          '환불 신청',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget useButton(gifticon) {
    String statusText = gifticonStatus(gifticon?.status, gifticon.validity);
    bool available = statusText == "사용가능" && gifticon.store_id != null;
    Widget useElevatedButton = SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          foregroundColor: Colors.white,
          backgroundColor:
              available ? ColorAssset.mainColor : Colors.grey[400],
          elevation: 0,
        ),
        onPressed: available == false
            ? null
            : () async {
                await ShowQR(gifticon.gifticon_id, gifticon.store_id!);
                if (!mounted) return;
                Provider.of<UserProvider>(context, listen: false).invalidateGifticonCache();
                final refreshed = await GifticonPage.fetchGifticon(widget.gifticon_id);
                if (!mounted) return;
                if (refreshed?.status != gifticon.status) {
                  _didUseGifticon = true;
                }
                setState(() {
                  futureGifticon = Future.value(refreshed);
                });
              },
        child: Text(
          '사용하기',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    if (!_canRequestReceiverRefund(gifticon)) {
      return useElevatedButton;
    }

    return Row(
      children: [
        Expanded(flex: 1, child: refundRequestButton(gifticon)),
        SizedBox(width: 8),
        Expanded(flex: 2, child: useElevatedButton),
      ],
    );
  }

  Future<void> ShowQR(gifticonId, storeId) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'QR 코드',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.close, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: QrImageView(
                      data: "$storeId,$gifticonId",
                      version: QrVersions.auto,
                      size: 220.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '매장에서 QR 코드를 스캔해주세요',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _renderCard({
    required Key key,
    bool isBack = true,
  }) {
    if (isBack) {
      return QrImageView(
        data: '${widget.gifticon_id}',
        version: QrVersions.auto,
        size: 200.0,
      );
    } else {
      return Container(
        padding: EdgeInsets.all(20),
        child: Image.asset(
          'assets/menu.png',
          height: 250,
        ),
      );
    }
  }

  Widget _renderFront() {
    return _renderCard(
      key: ValueKey(true),
      isBack: false,
    );
  }

  Widget _renderBack() {
    return _renderCard(
      key: ValueKey(false),
      isBack: true,
    );
  }

  Widget wrapAnimatedBuilder(Widget widget, Animation<double> animation) {
    final rotate = Tween(begin: pi, end: 0.0).animate(animation);

    return AnimatedBuilder(
      animation: rotate,
      child: widget,
      builder: (_, widget) {
        final isBack = showFront
            ? widget!.key == ValueKey(true)
            : widget!.key != ValueKey(true);

        final value = isBack ? min(rotate.value, pi / 2) : rotate.value;

        var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.0025;

        tilt *= isBack ? -1.0 : 1.0;

        return Transform(
          transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
          alignment: Alignment.center,
          child: widget,
        );
      },
    );
  }

  Widget getDetailInfo(String storeName) {
    return Column(
      children: [Product_notice_information(storeName), Cancellation_refund_policy()],
    );
  }

  Widget Cancellation_refund_policy() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return FutureBuilder(
        future: loadAsset(
            'assets/terms/cancellation and refund policy and method.txt'),
        builder: (context, snapshot) {
          // snapshot은 Future 클래스가 포장하고 있는 객체를 data 속성으로 전달                        // Future<String>이기 때문에 data는 String이 된다.
          final contents = snapshot.data.toString();
          return ExpansionTile(
              title: Text(
                '취소/환불 정책 및 방법',
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    // fontSize: screenWidth * (16 / 360),
                    color: Colors.black),
              ),
              initiallyExpanded: false,
              // backgroundColor: Colors.white,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Text(
                      contents,
                      style: TextStyle(fontSize: 12),
                    ))
              ]);
        });
  }

  Future<String> loadAsset(String path) async {
    return await rootBundle.loadString(path);
    // return await DefaultAssetBundle.of(ctx).loadString('assets/2016_GDP.txt');
  }

  Widget Product_notice_information(String storeName) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    Widget rowWidget(String title, String rowContents) {
      return Column(
        children: [
          Divider(height: 3, color: Colors.grey),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch, // 자식들이 같은 높이 갖게 함
              children: [
                Container(
                  width: screenWidth * 0.25,
                  color: ColorAssset.grey1,
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.topLeft,
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      rowContents,
                      softWrap: true,
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return FutureBuilder(
        future: loadAsset('assets/terms/refund policy.txt'),
        builder: (context, snapshot) {
          // snapshot은 Future 클래스가 포장하고 있는 객체를 data 속성으로 전달                        // Future<String>이기 때문에 data는 String이 된다.
          final contents = snapshot.data.toString();
          return ExpansionTile(
              title: Text(
                '기본 정보',
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    // fontSize: screenWidth * (16 / 360),
                    color: Colors.black,
                    fontSize: 14),
              ),
              initiallyExpanded: false,
              // backgroundColor: Colors.white,
              children: <Widget>[
                Column(children: [
                  rowWidget('발행자', '502 컴퍼니'),
                  rowWidget('교환권 공급자', storeName),
                  rowWidget('유효기간', '발급일 포함 365일'),
                  // rowWidget('환불조건 및 방법', contents),
                ])
                // )
              ]);
        });
  }

  // ✅ 사용된 기프티콘이면 회색 오버레이 추가
  Widget usedOverlay(Gifticon gifticon) {
    if (isUsed(gifticon)) {
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black.withOpacity(0.5),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 18, color: Colors.grey[800]),
                SizedBox(width: 8),
                Text(
                  "사용완료",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[900],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return SizedBox();
  }

  // ✅ 기프티콘이 사용되었는지 판별
  bool isUsed(Gifticon gifticon) {
    return gifticon.status == 'USED' ||
        gifticon.status == 'EXPIRED' ||
        gifticon.status == 'CANCELED' ||
        (gifticon.validity != null &&
            gifticon.validity!.isBefore(DateTime.now()));
  }

  // ✅ 메뉴 이미지 빌드 (URL 유효성 검사 포함)
  Widget _buildMenuImage(String? menuUrl) {
    final cleanedUrl = menuUrl?.trim() ?? '';

    // URL이 비어있거나 유효하지 않은 경우
    if (cleanedUrl.isEmpty ||
        (!cleanedUrl.startsWith('http://') &&
            !cleanedUrl.startsWith('https://'))) {
      // 이미지가 없을 때 예쁜 플레이스홀더 표시
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[100]!,
              Colors.grey[200]!,
            ],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.card_giftcard,
            size: 80,
            color: Colors.grey[400],
          ),
        ),
      );
    }

    // 유효한 URL이 있을 때 네트워크 이미지 표시
    return Image.network(
      cleanedUrl,
      width: 200,
      height: 200,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[100]!,
                Colors.grey[200]!,
              ],
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // 네트워크 이미지 로드 실패 시 플레이스홀더 표시
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[100]!,
                Colors.grey[200]!,
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.card_giftcard,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
        );
      },
    );
  }
}

class NaverMapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;

  const NaverMapWidget(
      {super.key, required this.latitude, required this.longitude});

  @override
  _NaverMapWidgetState createState() => _NaverMapWidgetState();
}

class _NaverMapWidgetState extends State<NaverMapWidget>
    with AutomaticKeepAliveClientMixin {
  late NaverMapController _mapController;
  final Completer<NaverMapController> mapControllerCompleter = Completer();
  bool _isMapReady = false;
  bool _isDisposed = false;
  NOverlayImage? _markerIcon;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_markerIcon == null) {
      _initMarkerIcon();
    }
  }

  Future<void> _initMarkerIcon() async {
    if (!mounted) return;

    try {
      // iOS에서는 fromAssetImage 사용, Android에서는 fromWidget 사용
      if (Platform.isIOS) {
        // iOS: asset 이미지를 직접 사용 (크기 파라미터 없음)
        _markerIcon = await NOverlayImage.fromAssetImage('assets/pin.png');
      } else {
        // Android: fromWidget 사용 (크기 조정 가능)
        if (!mounted) return;
        _markerIcon = await NOverlayImage.fromWidget(
          context: context,
          widget: SizedBox(
            width: 45,
            height: 60,
            child: Image.asset('assets/pin.png', fit: BoxFit.contain),
          ),
          size: const Size(45, 60),
        );
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // 오류가 발생해도 계속 진행
      // fallback으로 asset 이미지 직접 사용 시도
      try {
        if (_markerIcon == null) {
          _markerIcon = await NOverlayImage.fromAssetImage('assets/pin.png');
        }
        if (mounted) {
          setState(() {});
        }
      } catch (fallbackError) {
      }
    }
  }

  Future<void> _addMarker() async {
    if (_isDisposed || !_isMapReady) {
      return;
    }

    // 마커 아이콘이 없으면 초기화 시도
    if (_markerIcon == null) {
      await _initMarkerIcon();
      if (_markerIcon == null || _isDisposed || !_isMapReady) {
        return;
      }
    }

    try {
      final marker = NMarker(
        id: 'store',
        position: NLatLng(widget.latitude, widget.longitude),
      );

      // 아이콘 설정
      if (_markerIcon != null) {
        marker.setIcon(_markerIcon!);
      } else {
        // 아이콘이 여전히 null이면 기본 아이콘 생성 시도
        try {
          final defaultIcon =
              await NOverlayImage.fromAssetImage('assets/pin.png');
          marker.setIcon(defaultIcon);
          _markerIcon = defaultIcon; // 캐시에 저장
        } catch (iconError) {
          // 아이콘 없이 마커 추가 시도 (기본 마커 사용)
        }
      }

      await _mapController.addOverlay(marker);
    } catch (e) {
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    // 지도 컨트롤러 정리
    if (_isMapReady && mapControllerCompleter.isCompleted) {
      try {
        _mapController.dispose();
      } catch (e) {
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 요구사항

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      height: MediaQuery.of(context).size.height / 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: NaverMap(
          options: NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
              target: NLatLng(widget.latitude, widget.longitude),
              zoom: 13,
            ),
            indoorEnable: true,
            locationButtonEnable: true,
            consumeSymbolTapEvents: false,
          ),
          onMapReady: (controller) async {
            if (_isMapReady || _isDisposed) return;
            _isMapReady = true;

            if (_isDisposed) return;
            _mapController = controller;
            if (!mapControllerCompleter.isCompleted) {
              mapControllerCompleter.complete(controller);
            }


            // 지도가 준비되면 마커 추가
            if (!_isDisposed) {
              // 마커 아이콘이 없으면 먼저 초기화
              if (_markerIcon == null) {
                await _initMarkerIcon();
              }

              // 아이콘이 준비될 때까지 대기 (최대 3초)
              int retryCount = 0;
              while (_markerIcon == null && retryCount < 30 && !_isDisposed) {
                await Future.delayed(Duration(milliseconds: 100));
                retryCount++;
              }

              // 약간의 지연 후 마커 추가 (지도 렌더링 완료 대기)
              await Future.delayed(Duration(milliseconds: 300));
              if (!_isDisposed && _isMapReady) {
                await _addMarker();
              }
            }
          },
        ),
      ),
    );
  }
}

Color hexToColor(String hexString) {
  String hexStr = hexString.replaceAll('#', '');
  if (hexStr.length == 6) {
    hexStr = "FF$hexStr";
  }
  return Color(int.parse(hexStr, radix: 16));
}
