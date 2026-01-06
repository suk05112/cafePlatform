import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cafeplatform/Payment/Payment.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/Payment/CommonPaymentWidget.dart';
import 'package:cafeplatform/model/menu.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:cafeplatform/static/payment_guide_text.dart';

class SelectGiftPage extends StatefulWidget {
  const SelectGiftPage({super.key, required this.menu});

  final Menu menu; // 메뉴 객체를 저장할 필드 추가

  @override
  State<SelectGiftPage> createState() => _SelectGiftPagePageState();
}

class _SelectGiftPagePageState extends State<SelectGiftPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const CommonAppBar(title: "선물하기"),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 상품 정보 영역
                      CommonPaymentWidget.getGiftInfo(),
                      const SizedBox(height: 16),

                      // 사용방법 섹션
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '사용방법',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '실물 배송 상품이 아닌 교환처에서 사용할 수 있는 모바일 상품권입니다.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '상품권 사용시 QR코드 또는 상품권 번호를 매장에 제시해 주시면 됩니다',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '[주문/결제 → 상품권 수신 → 선물함 - QR코드 제시]',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 이용안내 / 유의사항 탭 영역
                      SizedBox(
                        height: 400,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SizedBox(
                                height: 50,
                                child: TabBar(
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
                                  labelColor: Colors.black,
                                  unselectedLabelColor: Colors.grey,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  indicatorPadding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  tabs: const [
                                    Tab(
                                      child: Text(
                                        "이용안내",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    Tab(
                                      child: Text(
                                        "유의사항",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  SingleChildScrollView(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        UsageGuide(),
                                      ],
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          PaymentGuideText.precautions,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Cancellation_refund_policy(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 하단 버튼 영역
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          foregroundColor: Colors.white,
                          backgroundColor: ColorAssset.mainColor,
                        ),
                        child: const Text(
                          '지금 바로 결제하기',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Payment(
                                type: 0,
                                menu: widget.menu,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          foregroundColor: ColorAssset.mainColor,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                              color: ColorAssset.mainColor, width: 1),
                        ),
                        child: const Text(
                          '선물하기',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Payment(type: 2, menu: widget.menu),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> loadAsset(String path) async {
    return await rootBundle.loadString(path);
    // return await DefaultAssetBundle.of(ctx).loadString('assets/2016_GDP.txt');
  }

  Widget UsageGuide() {
    return FutureBuilder<String>(
      future: loadAsset('assets/terms/usage_guide.txt'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                snapshot.data!,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text(
            '파일을 불러오는 중 오류가 발생했습니다.',
            style: const TextStyle(fontSize: 12),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget Cancellation_refund_policy() {
    return FutureBuilder<String>(
      future: loadAsset(
          'assets/terms/cancellation and refund policy and method.txt'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(
            snapshot.data!,
            style: const TextStyle(fontSize: 12),
          );
        } else if (snapshot.hasError) {
          return Text(
            '파일을 불러오는 중 오류가 발생했습니다.',
            style: const TextStyle(fontSize: 12),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
