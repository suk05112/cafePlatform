// import 'package:bootpay/bootpay.dart';
// import 'package:bootpay/model/payload.dart';
// import 'package:bootpay/model/user.dart' as bt;
// import 'package:bootpay/model/extra.dart' as bt_ex;
// import 'package:bootpay/model/item.dart';
import 'package:flutter/material.dart';
import 'package:cafeplatform/Payment/CompletePayment.dart';
import 'package:cafeplatform/Payment/payletter_webview_page.dart';
import 'package:cafeplatform/api/payment_url_request.dart';
import 'package:cafeplatform/api/payment_url_response.dart';
import 'package:cafeplatform/utils/kakao_share_helper.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/model/gifticon.dart';
import 'package:cafeplatform/model/menu.dart';
import 'package:cafeplatform/model/user.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:cafeplatform/terms/payment_terms.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:cafeplatform/Payment/figma_payment_method_section.dart';
import 'package:cafeplatform/Payment/payment_ui_tokens.dart';
import 'package:provider/provider.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';
import 'package:tosspayments_widget_sdk_flutter/payment_widget.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/agreement.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/payment_method.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:cafeplatform/utils/number_formatter.dart';
import 'package:cafeplatform/SignIn/login_page.dart';

/// true: Figma(1683:764) 결제 UI · 토스 위젯 미사용 · PG 연동 전
const bool _kUseFigmaPaymentUi = true;

class Payment extends StatefulWidget {
  const Payment({
    super.key,
    required this.type,
    required this.menu,
    this.exchangeAddress,
    this.exchangeLat,
    this.exchangeLng,
    this.exchangePlaceName,
    /// 매장 화면 등에서 `menu.store_id`가 0일 때 교환처 API 조회용
    this.contextStoreId,
    /// 주문정보 행 매장명 (없으면 생략)
    this.storeDisplayName,
  });

  final int type;
  final Menu menu;
  final String? exchangeAddress;
  final double? exchangeLat;
  final double? exchangeLng;
  final String? exchangePlaceName;
  final int? contextStoreId;
  final String? storeDisplayName;

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String receiver = "";
  String receiverPhoneNumber = "";

  // 토스페이먼츠 위젯 관련 상태 (_kUseFigmaPaymentUi 이면 미사용)
  PaymentWidget? _paymentWidget;
  PaymentMethodWidgetControl? _paymentMethodWidgetControl;
  AgreementWidgetControl? _agreementWidgetControl;

  /// Figma 결제수단 UI
  String _figmaPaymentLabel = '카카오페이';
  bool _figmaTermsAgreed = false;

  // 결제 위젯 로딩 상태
  bool _isLoadingWidgets = true;
  bool _isSubmitting = false;

  void _checkWidgetsReady() {
    if (_paymentMethodWidgetControl != null &&
        _agreementWidgetControl != null) {
      if (mounted) {
        setState(() {
          _isLoadingWidgets = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    print("Payment initState ${widget.menu.name} ${widget.menu.store_id}");

    if (_kUseFigmaPaymentUi) {
      _isLoadingWidgets = false;
    } else {
      _paymentWidget = PaymentWidget(
        clientKey: "test_gck_docs_Ovk5rk1EwkEbP0W43n07xlzm",
        customerKey: "zG5XLcHhA7c3tuJsV_H3j",
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            try {
              _renderPaymentWidgets();
            } catch (e) {
              print("PaymentWidget 초기화 오류: $e");
              if (mounted) {
                setState(() {
                  _isLoadingWidgets = false;
                });
              }
            }
          }
        });
      });
    }
  }

  void _renderPaymentWidgets() {
    if (!mounted || _paymentWidget == null) return;

    try {
      _paymentWidget!
          .renderPaymentMethods(
        selector: 'payment-methods',
        amount: Amount(
          value: widget.menu.price,
          currency: Currency.KRW,
          country: "KR",
        ),
        options: RenderPaymentMethodsOptions(variantKey: "DEFAULT"),
      )
          .then((control) {
        if (mounted) {
          setState(() {
            _paymentMethodWidgetControl = control;
          });
          _checkWidgetsReady();
        }
      }).catchError((error, stackTrace) {
        print("결제수단 위젯 렌더링 오류: $error");
        print("스택 트레이스: $stackTrace");
        if (mounted) {
          setState(() {
            _isLoadingWidgets = false;
          });
        }
      });

      _paymentWidget!
          .renderAgreement(selector: 'payment-agreement')
          .then((control) {
        if (mounted) {
          setState(() {
            _agreementWidgetControl = control;
          });
          _checkWidgetsReady();
        }
      }).catchError((error, stackTrace) {
        print("약관 위젯 렌더링 오류: $error");
        print("스택 트레이스: $stackTrace");
        if (mounted) {
          setState(() {
            _isLoadingWidgets = false;
          });
        }
      });
    } catch (e, stackTrace) {
      print("_renderPaymentWidgets 오류: $e");
      print("스택 트레이스: $stackTrace");
      if (mounted) {
        setState(() {
          _isLoadingWidgets = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // PaymentWidget 리소스 정리
    try {
      _paymentMethodWidgetControl = null;
      _agreementWidgetControl = null;
    } catch (e) {
      print("PaymentWidget 정리 중 오류: $e");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int type = widget.type;
    final menu = widget.menu;
    int price = menu.price;
    int discount = 0; // 실제 할인 적용시 로직 확장
    int finalPrice = price - discount;
    return GestureDetector(
      onTap: () {
        // 화면 탭 시 키보드 닫기
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
          Scaffold(
        appBar: CommonAppBar(title: type == 2 ? "선물하기" : "결제하기"),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 주문정보 (Figma 1683:764)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("주문정보",
                                style: PaymentUiTokens.sectionTitle),
                            const SizedBox(height: 12),
                            _buildFigmaOrderInfo(),
                          ],
                        ),
                      ),
                      Container(
                          height: 14,
                          width: double.infinity,
                          color: PaymentUiTokens.bar),

                      if (type == 2) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                          child: ReceiverInfo(
                              onInputChanged: (receiverName, phoneNumber) {
                            setState(() {
                              receiver = receiverName;
                              receiverPhoneNumber = phoneNumber;
                            });
                          }),
                        ),
                        Container(
                            height: 14,
                            width: double.infinity,
                            color: PaymentUiTokens.bar),
                      ],

                      /// 결제 수단
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("결제 수단",
                                style: PaymentUiTokens.sectionTitle),
                            const SizedBox(height: 12),
                            if (_kUseFigmaPaymentUi) ...[
                              FigmaPaymentMethodSection(
                                initialSelection: _figmaPaymentLabel,
                                onSelectionChanged: (label) {
                                  setState(() => _figmaPaymentLabel = label);
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _figmaTermsAgreed,
                                      activeColor: ColorAssset.mainColor,
                                      onChanged: (v) => setState(
                                          () => _figmaTermsAgreed = v ?? false),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (context) =>
                                                Payment_Terms(),
                                          ),
                                        );
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.only(top: 2),
                                        child: Text(
                                          '결제 및 개인정보 처리에 동의합니다. (필수)',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                            height: 1.35,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else
                              Stack(
                                children: [
                                  Opacity(
                                    opacity: _isLoadingWidgets ? 0.0 : 1.0,
                                    child: Column(
                                      children: [
                                        PaymentMethodWidget(
                                          paymentWidget: _paymentWidget!,
                                          selector: 'payment-methods',
                                        ),
                                        const SizedBox(height: 12),
                                        AgreementWidget(
                                          paymentWidget: _paymentWidget!,
                                          selector: 'payment-agreement',
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_isLoadingWidgets)
                                    const SizedBox(
                                      height: 200,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      Container(
                          height: 14,
                          width: double.infinity,
                          color: Color(0xFFF5F6FA)),

                      /// 결제정보(금액)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("결제정보",
                                style: PaymentUiTokens.sectionTitle),
                            const SizedBox(height: 10),
                            _priceRow("총 상품금액", price),
                            const SizedBox(height: 5),
                            _priceRow("할인금액", discount),
                            const Divider(
                                height: 1, color: PaymentUiTokens.divider),
                            const SizedBox(height: 5),
                            _priceRow("최종 결제금액", finalPrice, bold: true),
                          ],
                        ),
                      ),
                      Container(
                          height: 14,
                          width: double.infinity,
                          color: PaymentUiTokens.bar),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 20),
                      //   child: Notice(),
                      // ),
                    ],
                  ),
                ),
              ),
              _buildPaymentButton(),
            ],
          ),
        ),
          ),
          if (_isSubmitting)
            const ModalBarrier(dismissible: false, color: Colors.black26),
          if (_isSubmitting)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  /// 단일 금액 Row
  Widget _priceRow(String label, int amount, {bool bold = false}) {
    final priceStr = amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                color: PaymentUiTokens.labelMuted,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
        Text("$priceStr원",
            style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
      ],
    );
  }

  /// Figma 1683:764 주문정보 행 (56² 썸네일 · 매장 · 메뉴명 · 가격)
  Widget _buildFigmaOrderInfo() {
    final menu = widget.menu;
    final store = widget.storeDisplayName?.trim() ?? '';
    final priceStr = menu.price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    final hasImg = menu.menu_image_url != null &&
        menu.menu_image_url!.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 56,
            height: 56,
            child: hasImg
                ? Image.network(
                    menu.menu_image_url!.trim(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: const Color(0xFFE6E6E6),
                      child: Icon(Icons.local_cafe_outlined,
                          color: Colors.grey.shade400),
                    ),
                  )
                : ColoredBox(
                    color: const Color(0xFFE6E6E6),
                    child: Icon(Icons.local_cafe_outlined,
                        color: Colors.grey.shade400),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (store.isNotEmpty)
                Text(
                  store,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: PaymentUiTokens.orderStore,
                    height: 1.2,
                  ),
                ),
              Text(
                menu.name ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: PaymentUiTokens.orderText,
                  height: 22.5 / 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$priceStr원',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: PaymentUiTokens.orderText,
                  height: 22.5 / 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget TotalPrice(int price) {
    return Row(
      children: [
        SizedBox(
          height: 10,
        ),
        Text("결제금액"),
        Spacer(),
        Text("$price원"),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget Notice() {
    return Column(children: [
      // Text("주문 내용 및 결제 조건을 확인했으며, 결제 진행에 동의합니다."),
      // Text("이벤트 상품에는 쿠폰 할인이 적용되지 않습니다."),
      // Text("최소 결제 금액은 일반 상품 금액 대상으로 책정돕니다."),
      GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => Payment_Terms()));
          },
          child: Text(
            "주문 내용 및 결제 조건을 확인했으며, 결제 진행에 동의합니다.",
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          )),
    ]);
  }

  Widget _buildPaymentButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            foregroundColor: Colors.white,
            backgroundColor: ColorAssset.mainColor,
          ),
          onPressed: _submitCheckout,
          child: Text(
            '${widget.menu.price}원 결제하기',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitCheckout() async {
    FocusScope.of(context).unfocus();

    late final String paymentValue;
    if (_kUseFigmaPaymentUi) {
      if (!_figmaTermsAgreed) {
        _showToast('결제 약관에 동의해 주세요.');
        return;
      }
      if (_figmaPaymentLabel.isEmpty) {
        _showToast('결제수단을 선택해주세요.');
        return;
      }
      paymentValue = _figmaPaymentLabel;
    } else {
      if (_agreementWidgetControl == null ||
          _paymentMethodWidgetControl == null) {
        _showToast('결제위젯이 준비되지 않았습니다.');
        return;
      }

      final agreement = await _agreementWidgetControl?.getAgreementStatus();
      if (agreement?.agreedRequiredTerms != true) {
        _showToast('필수 약관에 모두 동의해주세요.');
        return;
      }

      final selectedPaymentMethod =
          await _paymentMethodWidgetControl?.getSelectedPaymentMethod();

      if (selectedPaymentMethod == null) {
        _showToast('결제수단을 선택해주세요.');
        return;
      }

      print('선택된 결제수단: ${selectedPaymentMethod.method}');
      final method = selectedPaymentMethod.method?.toLowerCase() ?? '';
      if (method == 'card') {
        paymentValue = '카드';
      } else if (selectedPaymentMethod.easyPay != null) {
        paymentValue =
            selectedPaymentMethod.easyPay!.provider ?? '간편결제';
      } else {
        paymentValue = selectedPaymentMethod.method ?? '기타';
      }
    }
    print('결제 수단: $paymentValue');

    if (widget.type == 2) {
      if (receiver.trim().isEmpty) {
        _showToast('받는 분의 이름을 입력해주세요.');
        return;
      }
      if (receiverPhoneNumber.trim().isEmpty) {
        _showToast('받는 분의 전화번호를 입력해주세요.');
        return;
      }
      final phoneNumber =
          receiverPhoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      if (phoneNumber.length != 10 && phoneNumber.length != 11) {
        _showToast('올바른 전화번호를 입력해주세요. (10-11자리)');
        return;
      }
      final phonePattern = RegExp(r'^010-\d{4}-\d{4}$');
      if (!phonePattern.hasMatch(receiverPhoneNumber)) {
        _showToast('전화번호 형식이 올바르지 않습니다. (예: 010-1234-5678)');
        return;
      }
    }

    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(returnToPrevious: true),
        ),
      );
      return;
    }

    final storeId = widget.menu.store_id > 0
        ? widget.menu.store_id
        : (widget.contextStoreId ?? 0);
    if (storeId <= 0) {
      _showToast('유효하지 않은 메뉴 정보입니다. 다시 선택해주세요.');
      print(
          'ERROR: Invalid store_id: $storeId (menu_id: ${widget.menu.menu_id})');
      return;
    }

    final rawPhone = receiverPhoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final pgcode = _toPgcode(paymentValue);

    final request = PaymentUrlRequest(
      type: widget.type,
      sender: user.name,
      receiver: widget.type == 2 ? receiver : user.name,
      receiverPhoneNumber: rawPhone,
      menuId: widget.menu.menu_id ?? 0,
      storeId: storeId,
      totalPrice: widget.menu.price,
      pgcode: pgcode,
      payment: paymentValue,
    );

    print('결제 URL 요청 - user_id: ${user.user_id}, store_id: $storeId, pgcode: $pgcode');

    setState(() => _isSubmitting = true);
    try {
      await Api().setBaseClient(Api.BASE_URL);
      final PaymentUrlResponse paymentUrlResponse =
          await Api().client.getPaymentUrl(user.user_id, request);

      print('결제 URL 수신 - order_id: ${paymentUrlResponse.orderId}, mobile_url: ${paymentUrlResponse.mobileUrl}');

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      final resultData = await Navigator.of(context).push<PayletterResultData>(
        MaterialPageRoute(
          builder: (_) => PayletterWebViewPage(
            mobileUrl: paymentUrlResponse.mobileUrl,
          ),
        ),
      );

      if (!mounted) return;

      if (resultData?.result == PayletterResult.success) {
        final gifticon = Gifticon()
          ..gifticon_id = paymentUrlResponse.gifticonId
          ..order_id = paymentUrlResponse.orderId
          ..order_no = paymentUrlResponse.orderNo
          ..store_id = storeId
          ..type = widget.type
          ..name = widget.menu.name ?? ''
          ..sender = user.name
          ..receiver = widget.type == 2 ? receiver : user.name
          ..receiver_phone_number = rawPhone
          ..payment = paymentValue
          ..menu_id = widget.menu.menu_id
          ..total_price = widget.menu.price;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => CompletePayment(
              giftType: widget.type,
              gifticon: gifticon,
            ),
          ),
        );
      } else if (resultData?.result == PayletterResult.cancel) {
        _showToast('결제가 취소되었습니다.');
      } else if (resultData?.result == PayletterResult.fail) {
        final msg = resultData?.message;
        _showToast(msg != null && msg.isNotEmpty ? msg : '결제에 실패했습니다. 다시 시도해주세요.');
      }
    } on DioException catch (e) {
      print('결제 URL 요청 실패: $e');
      if (mounted) setState(() => _isSubmitting = false);

      if (e.response?.statusCode == 500) {
        final errorMessage = e.response?.data?.toString() ?? '';
        if (errorMessage.contains('foreign key constraint') ||
            errorMessage.contains('store_id') ||
            errorMessage.contains('Cannot add or update a child row')) {
          _showToast('유효하지 않은 가게 정보입니다. 메뉴를 다시 선택해주세요.');
          print('ERROR: Foreign key constraint failed for store_id: $storeId');
          return;
        }
      }

      _showToast('결제 요청에 실패했습니다. 다시 시도해주세요.');
    } catch (e) {
      print('결제 오류: $e');
      if (mounted) setState(() => _isSubmitting = false);
      _showToast('결제 중 오류가 발생했습니다.');
    }
  }

  String _toPgcode(String label) {
    const map = {
      'KB카드': 'creditcard',
      '신한카드': 'creditcard',
      '하나카드': 'creditcard',
      '우리카드': 'creditcard',
      '삼성카드': 'creditcard',
      '롯데카드': 'creditcard',
      '현대카드': 'creditcard',
      '농협카드': 'creditcard',
      '카카오페이': 'kakaopay',
      '네이버페이': 'naverpay',
      '페이코': 'payco',
    };
    return map[label] ?? 'creditcard';
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  Future<void> shareKaKaotalk(Gifticon gifticon) async {
    await KakaoShareHelper.shareGifticon(
      gifticon,
      onSuccess: () {
        print('카카오톡 공유 완료');
      },
      onError: (error) {
        print('카카오톡 공유 실패: $error');
      },
    );
  }
}

class ApplyCoupons extends StatelessWidget {
  const ApplyCoupons({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text('사용가능쿠폰'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '받을 분의 전화번호를 입력해 주세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
              ),
              Text("찾아보기"),
            ],
          ),
          Row(
            children: [Text('00카페 20%할인쿠폰'), Text('적용완료')],
          )
        ],
      ),
    );
  }
}

class ApplyPoints extends StatelessWidget {
  const ApplyPoints({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text("포인트"),
          TextField(
            decoration: InputDecoration(
              hintText: '20000원 이용가능',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class paymentBtn extends StatefulWidget {
  const paymentBtn({
    super.key,
    required this.type,
    required this.menu,
    required this.receiver,
    required this.receiverPhoneNumber,
  });

  final int type;
  final Menu menu;
  final String receiver;
  final String receiverPhoneNumber;

  @override
  _paymentBtn createState() =>
      _paymentBtn(); // StatefulWidget은 상태를 생성하는 createState() 메서드로 구현한다.
}

class _paymentBtn extends State<paymentBtn> {
  String webApplicationId = '6757d28731d38115ba3fc912';
  String androidApplicationId = '6757d28731d38115ba3fc913';
  String iosApplicationId = '6757d28731d38115ba3fc914';

  @override
  Widget build(BuildContext context) {
    final menu = widget.menu;

    User? user = Provider.of<UserProvider>(context).user;

    return Center(
        // Elevated Button 위젯
        child: SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          foregroundColor: Colors.white,
          backgroundColor: ColorAssset.mainColor,
        ),
        child: Text('${menu.price}원 결제하기'),

        // 클릭 이벤트
        onPressed: () {
          // setState() 메서드를 수행시 다시 build() 메서드가 실행되며 동적 화면이 구현된다.
          setState(() {
            Gifticon gifticon = Gifticon();
            gifticon.store_id = widget.menu.store_id;
            gifticon.type = widget.type;
            gifticon.name = menu.name ?? "";
            gifticon.sender = user?.name ?? "user is null";
            gifticon.receiver = widget.receiver;
            gifticon.receiver_phone_number = widget.receiverPhoneNumber;
            gifticon.payment = "kakao";
            gifticon.menu_id = widget.menu.menu_id;
            gifticon.total_price = widget.menu.price;
            // bootpayTest(context, gifticon, _menu);

            print("user info: ${user?.user_id}, ${user?.email}, ${user?.name}");
            // shareKaKaotalk(gifticon);
            // Api()
            //     .client
            //     .purchaseGifticon(user?.user_id ?? 0, gifticon)
            //     .then((value) {
            //   if (value.statusCode == 200) {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => CompletePayment()),
            //     );
            //   } else {
            //     print("결제 실패");
            //   }
            // });
          });
        },
      ),
    ));
  }

/*
  void bootpayTest(BuildContext context, Gifticon gifticon, Menu menu) {
    Payload payload = getPayload(gifticon, menu);
    if (kIsWeb) {
      payload.extra?.openType = "iframe";
    }

    Bootpay().requestPayment(
      context: context,
      payload: payload,
      showCloseButton: false,
      // closeButton: Icon(Icons.close, size: 35.0, color: Colors.black54),
      onCancel: (String data) {
        print('------- onCancel: $data');
      },
      onError: (String data) {
        print('------- onError: $data');
      },
      onClose: () {
        print('------- onClose');
        Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출
        //TODO - 원하시는 라우터로 페이지 이동
      },
      onIssued: (String data) {
        print('------- onIssued: $data');
      },
      onConfirm: (String data) {
        print('------- onConfirm: $data');
        /**
            1. 바로 승인하고자 할 때
            return true;
         **/
        /***
            2. 비동기 승인 하고자 할 때
            checkQtyFromServer(data);
            return false;
         ***/
        /***
            3. 서버승인을 하고자 하실 때 (클라이언트 승인 X)
            return false; 후에 서버에서 결제승인 수행
         */
        // checkQtyFromServer(data);
        return true;
      },
      onDone: (String data) {
        print('------- onDone: $data');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CompletePayment()),
        );
      },
    );
  }
  */
}

/*
  Payload getPayload(Gifticon gifticon, Menu menu) {
    User? providedUser = Provider.of<UserProvider>(context).user;

    Payload payload = Payload();
    Item item1 = Item();
    item1.name = gifticon.name; // 주문정보에 담길 상품명
    item1.qty = 1; // 해당 상품의 주문 수량
    item1.id = "${menu.menu_id}"; // 해당 상품의 고유 키
    item1.price = menu.price.toDouble(); // 상품의 가격

    List<Item> itemList = [item1];

    payload.webApplicationId = webApplicationId; // web application id
    payload.androidApplicationId =
        androidApplicationId; // android application id
    payload.iosApplicationId = iosApplicationId; // ios application id

    payload.pg = '나이스페이';
    // payload.method = '카드';
    payload.methods = ['card', 'phone', 'vbank', 'bank', 'kakao', 'npay'];
    payload.orderName = gifticon.name;
    //결제할 상품명
    payload.price = menu.price.toDouble(); //정기결제시 0 혹은 주석

    payload.orderId =
        "a9d1b5c626c057c76682c2c03445f19d3634b5a74bf8fb5cf816ad37eb29e5ca.4469490dd1a9062c83f55129054ed763";

    // payload.metadata = {
    //   "callbackParam1" : "value12",
    //   "callbackParam2" : "value34",
    //   "callbackParam3" : "value56",
    //   "callbackParam4" : "value78",
    // }; // 전달할 파라미터, 결제 후 되돌려 주는 값
    payload.items = itemList; // 상품정보 배열

    bt.User user = bt.User(); // 구매자 정보
    user.username = providedUser?.name;
    user.email = providedUser?.email;
    // user.area = "서울";
    user.phone = providedUser?.phone_number;
    // user.addr = '서울시 동작구 상도로 222';

    bt_ex.Extra extra = bt_ex.Extra(); // 결제 옵션
    extra.appScheme = '502company';

    payload.user = user;
    payload.extra = extra;
    return payload;
  }
}

*/
class ReceiverInfo extends StatefulWidget {
  final Function(String receiver, String receiverPhoneNumber) onInputChanged;

  const ReceiverInfo({super.key, required this.onInputChanged});

  @override
  State<ReceiverInfo> createState() => _ReceiverInfoState();
}

class _ReceiverInfoState extends State<ReceiverInfo> {
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _receiver = "";
  String _receiverPhoneNumber = "";

  @override
  void dispose() {
    _receiverController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: Color(0xFFE0E3E9)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('받는 분 정보',
            style: PaymentUiTokens.sectionTitle),
        const SizedBox(height: 12),
        TextField(
          controller: _receiverController,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            labelText: "받는 분 이름 *",
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: PaymentUiTokens.labelMuted),
            hintText: "받는 분의 이름을 입력해주세요",
            border: borderStyle,
            focusedBorder: borderStyle,
            enabledBorder: borderStyle,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          onChanged: (value) {
            setState(() {
              _receiver = value;
            });
            widget.onInputChanged(_receiver, _receiverPhoneNumber);
          },
        ),
        const SizedBox(height: 7),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 15),
          inputFormatters: [
            NumberFormatter(), // 하이픈 자동 삽입 (3-4-4 형식)
            LengthLimitingTextInputFormatter(13), // 010-1234-5678 (최대 13자)
          ],
          decoration: InputDecoration(
            labelText: "전화번호 *",
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: PaymentUiTokens.labelMuted),
            hintText: "받을 분의 전화번호를 입력해주세요 (예: 010-1234-5678)",
            border: borderStyle,
            focusedBorder: borderStyle,
            enabledBorder: borderStyle,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          onChanged: (value) {
            setState(() {
              _receiverPhoneNumber = value;
            });
            widget.onInputChanged(_receiver, _receiverPhoneNumber);
          },
        ),
        const SizedBox(height: 7),
        TextField(
          controller: _messageController,
          maxLines: 2,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            labelText: "메시지 (생략가능)",
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: PaymentUiTokens.labelMuted),
            hintText: "메시지를 입력해주세요",
            border: borderStyle,
            focusedBorder: borderStyle,
            enabledBorder: borderStyle,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "기프티콘은 카카오톡(문자)으로 전달됩니다.",
          style: TextStyle(
            fontSize: 11,
            color: PaymentUiTokens.captionGrey,
          ),
        ),
      ],
    );
  }
}
