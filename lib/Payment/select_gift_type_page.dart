import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cafeplatform/Payment/Payment.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/Payment/CommonPaymentWidget.dart';
import 'package:cafeplatform/model/menu.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:cafeplatform/static/payment_guide_text.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:cafeplatform/SignIn/login_page.dart';
import 'package:cafeplatform/utils/meta_analytics_service.dart';
import 'package:provider/provider.dart';

class SelectGiftPage extends StatefulWidget {
  const SelectGiftPage({
    super.key,
    required this.menu,
    this.exchangeAddress,
    this.exchangeLat,
    this.exchangeLng,
    this.exchangePlaceName,
    this.contextStoreId,
    this.loadStoreId,
  });

  final Menu menu;
  final String? exchangeAddress;
  final double? exchangeLat;
  final double? exchangeLng;
  final String? exchangePlaceName;
  final int? contextStoreId;
  /// 전달 시 initState에서 매장 정보를 로드해 exchangeAddress/Lat/Lng/PlaceName을 채움
  final int? loadStoreId;

  @override
  State<SelectGiftPage> createState() => _SelectGiftPagePageState();
}

class _SelectGiftPagePageState extends State<SelectGiftPage> {
  static const _termsPaths = (
    usage: 'assets/terms/usage_guide.txt',
    refund: 'assets/terms/cancellation and refund policy and function.txt',
  );

  int _guideTab = 0;
  String? _usageFromAsset;
  String? _refundFromAsset;
  bool _termsLoaded = false;

  String? _exchangeAddress;
  double? _exchangeLat;
  double? _exchangeLng;
  String? _exchangePlaceName;

  @override
  void initState() {
    super.initState();
    _exchangeAddress = widget.exchangeAddress;
    _exchangeLat = widget.exchangeLat;
    _exchangeLng = widget.exchangeLng;
    _exchangePlaceName = widget.exchangePlaceName;
    _loadTerms();
    if (widget.loadStoreId != null) _loadStoreInfo(widget.loadStoreId!);
  }

  Future<void> _loadStoreInfo(int storeId) async {
    try {
      await Api().setBaseClient(Api.BASE_URL);
      final resp = await Api().client.getStoreDetailInfo(storeId);
      if (!mounted) return;
      final s = resp.store;
      setState(() {
        _exchangeAddress = s.store_address;
        _exchangeLat = s.store_lat;
        _exchangeLng = s.store_lng;
        if (_exchangePlaceName == null || _exchangePlaceName!.isEmpty) {
          _exchangePlaceName = s.store_name;
        }
      });
    } catch (_) {}
  }

  Future<void> _loadTerms() async {
    try {
      final usage = await rootBundle.loadString(_termsPaths.usage);
      final refund = await rootBundle.loadString(_termsPaths.refund);
      if (!mounted) return;
      setState(() {
        _usageFromAsset = usage;
        _refundFromAsset = refund;
        _termsLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _usageFromAsset = null;
        _refundFromAsset = null;
        _termsLoaded = true;
      });
    }
  }

  Widget _guideTabBar() {
    Widget chip(int index, String label) {
      final on = _guideTab == index;
      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _guideTab = index),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 12),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              decoration: BoxDecoration(
                color: on ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: on
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: on ? Colors.black : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [chip(0, '이용안내'), chip(1, '유의사항')]),
    );
  }

  Widget _guideTabBody() {
    if (!_termsLoaded) {
      return const Center(child: CircularProgressIndicator(color: ColorAssset.mainColor));
    }
    if (_guideTab == 0) {
      return Text(
        _usageFromAsset ?? PaymentGuideText.usageGuide,
        style: const TextStyle(fontSize: 12, height: 1.45),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          PaymentGuideText.precautions,
          style: TextStyle(fontSize: 12, height: 1.45),
        ),
        if (_refundFromAsset != null && _refundFromAsset!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            _refundFromAsset!,
            style: const TextStyle(fontSize: 12, height: 1.45),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CommonAppBar(title: "선물하기"),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CommonPaymentWidget.buildGiftProductHeroImage(
                        context,
                        widget.menu,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CommonPaymentWidget.buildGiftProductCard(
                              context,
                              widget.menu,
                              exchangeAddress: _exchangeAddress,
                              exchangeLat: _exchangeLat,
                              exchangeLng: _exchangeLng,
                              exchangePlaceName: _exchangePlaceName,
                              contextStoreId: widget.contextStoreId ?? widget.loadStoreId,
                              asCard: false,
                              skipImage: true,
                            ),
                            const SizedBox(height: 20),

                            // 사용방법 섹션 (Figma 톤)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFE0E0E0)),
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
                                      '[주문/결제 → 상품권 수신 → 선물함 → QR코드 제시]',
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

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _guideTabBar(),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: _guideTabBody(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 하단 버튼 영역 (결제하기 화면 하단과 동일: 한 행 2버튼)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            final user = Provider.of<UserProvider>(context, listen: false).user;
                            if (user == null) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage(returnToPrevious: true)));
                              return;
                            }
                            MetaAnalyticsService.instance.logInitiateCheckout(
                              contentId: widget.menu.menu_id.toString(),
                              contentType: 'product',
                              value: widget.menu.price.toDouble(),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Payment(
                                  type: 0,
                                  menu: widget.menu,
                                  storeDisplayName: _exchangePlaceName,
                                  contextStoreId: widget.contextStoreId ?? widget.loadStoreId ??
                                      (widget.menu.store_id > 0
                                          ? widget.menu.store_id
                                          : null),
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ColorAssset.mainColor,
                            side: const BorderSide(
                                color: ColorAssset.mainColor, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: const Text(
                              '지금 바로 결제하기',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            foregroundColor: Colors.white,
                            backgroundColor: ColorAssset.mainColor,
                          ),
                          onPressed: () {
                            final user = Provider.of<UserProvider>(context, listen: false).user;
                            if (user == null) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage(returnToPrevious: true)));
                              return;
                            }
                            MetaAnalyticsService.instance.logInitiateCheckout(
                              contentId: widget.menu.menu_id.toString(),
                              contentType: 'product',
                              value: widget.menu.price.toDouble(),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Payment(
                                  type: 2,
                                  menu: widget.menu,
                                  storeDisplayName: _exchangePlaceName,
                                  exchangeAddress: _exchangeAddress,
                                  exchangeLat: _exchangeLat,
                                  exchangeLng: _exchangeLng,
                                  exchangePlaceName: _exchangePlaceName,
                                  contextStoreId: widget.contextStoreId ?? widget.loadStoreId ??
                                      (widget.menu.store_id > 0
                                          ? widget.menu.store_id
                                          : null),
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            '선물하기',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}
