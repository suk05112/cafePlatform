// import 'package:bootpay/bootpay.dart';
import 'package:cafeplatform/Extension/scaffold_messenger_extension.dart';
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
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:cafeplatform/terms/payment_terms.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:cafeplatform/Payment/figma_payment_method_section.dart';
import 'package:cafeplatform/utils/meta_analytics_service.dart';
import 'package:cafeplatform/Payment/payment_ui_tokens.dart';
import 'package:provider/provider.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';
import 'package:tosspayments_widget_sdk_flutter/payment_widget.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/agreement.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/payment_method.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:cafeplatform/SignIn/login_page.dart';
import 'package:uuid/uuid.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

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
  // bool _figmaTermsAgreed = false;

  String _idempotencyKey = const Uuid().v4();

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
        if (mounted) {
          setState(() {
            _isLoadingWidgets = false;
          });
        }
      });
    } catch (e, stackTrace) {
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
                              // const SizedBox(height: 16),
                              // Row(
                              //   crossAxisAlignment: CrossAxisAlignment.start,
                              //   children: [
                              //     SizedBox(
                              //       width: 24,
                              //       height: 24,
                              //       child: Checkbox(
                              //         value: _figmaTermsAgreed,
                              //         activeColor: ColorAssset.mainColor,
                              //         onChanged: (v) => setState(
                              //             () => _figmaTermsAgreed = v ?? false),
                              //       ),
                              //     ),
                              //     Expanded(
                              //       child: GestureDetector(
                              //         onTap: () {
                              //           Navigator.push(
                              //             context,
                              //             MaterialPageRoute<void>(
                              //               builder: (context) =>
                              //                   Payment_Terms(),
                              //             ),
                              //           );
                              //         },
                              //         child: const Padding(
                              //           padding: EdgeInsets.only(top: 2),
                              //           child: Text(
                              //             '결제 및 개인정보 처리에 동의합니다. (필수)',
                              //             style: TextStyle(
                              //               fontSize: 13,
                              //               color: Colors.black87,
                              //               height: 1.35,
                              //               decoration:
                              //                   TextDecoration.underline,
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              // ),
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
                                        child: CircularProgressIndicator(color: ColorAssset.mainColor),
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
            const Center(child: CircularProgressIndicator(color: ColorAssset.mainColor)),
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
      // if (!_figmaTermsAgreed) {
      //   _showToast('결제 약관에 동의해 주세요.');
      //   return;
      // }
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

    MetaAnalyticsService.instance.logInitiateCheckout(
      contentId: widget.menu.menu_id.toString(),
      contentType: 'product',
      value: widget.menu.price.toDouble(),
    );
    MetaAnalyticsService.instance.logAddPaymentInfo(success: true);

    if (widget.type == 2) {
      if (receiverPhoneNumber.trim().isEmpty) {
        _showToast('받는 분의 전화번호를 입력해주세요.');
        return;
      }
      final phoneDigits =
          receiverPhoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      if (!RegExp(r'^010\d{8}$').hasMatch(phoneDigits)) {
        _showToast('올바른 전화번호를 입력해주세요. (010-XXXX-XXXX)');
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
      idempotencyKey: _idempotencyKey,
    );


    setState(() => _isSubmitting = true);
    try {
      await Api().setBaseClient(Api.BASE_URL);
      final PaymentUrlResponse paymentUrlResponse =
          await Api().client.getPaymentUrl(user.user_id, request);


      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (paymentUrlResponse.mobileUrl.isEmpty) {
        _showToast('결제 URL을 받지 못했습니다. 다시 시도해주세요.');
        setState(() => _idempotencyKey = const Uuid().v4());
        return;
      }

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
        setState(() => _idempotencyKey = const Uuid().v4());
        _showToast('결제가 취소되었습니다.');
      } else if (resultData?.result == PayletterResult.fail) {
        setState(() => _idempotencyKey = const Uuid().v4());
        final msg = resultData?.message;
        _showToast(msg != null && msg.isNotEmpty ? msg : '결제에 실패했습니다. 다시 시도해주세요.');
      }
    } on DioException catch (e) {
      if (mounted) setState(() => _isSubmitting = false);

      if (e.response?.statusCode == 500) {
        final errorMessage = e.response?.data?.toString() ?? '';
        if (errorMessage.contains('foreign key constraint') ||
            errorMessage.contains('store_id') ||
            errorMessage.contains('Cannot add or update a child row')) {
          _showToast('유효하지 않은 가게 정보입니다. 메뉴를 다시 선택해주세요.');
          return;
        }
      }

      // 네트워크 오류 시 동일 UUID 재사용 (서버 중복 차단)
      _showToast('결제 요청에 실패했습니다. 다시 시도해주세요.');
    } catch (e) {
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
      },
      onError: (error) {
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
  String? _name;
  String? _phone;

  static String _digitsOnly(String phone) =>
      phone.replaceAll(RegExp(r'[^\d]'), '');

  static String _formatPhone(String digits) {
    if (digits.length == 11) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    } else if (digits.length == 10) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return digits;
  }

  static bool _isValidPhone(String digits) =>
      RegExp(r'^010\d{8}$').hasMatch(digits);

  void _setRecipient(String name, String phone) {
    setState(() {
      _name = name;
      _phone = phone;
    });
    widget.onInputChanged(name, phone);
  }

  void _clearRecipient() {
    setState(() {
      _name = null;
      _phone = null;
    });
    widget.onInputChanged('', '');
  }

  Future<void> _pickFromContacts() async {
    final status = await Permission.contacts.request();
    debugPrint('[ReceiverInfo] contacts permission status: $status');
    if (status.isGranted || status.isLimited) {
      final contacts = await FastContacts.getAllContacts(
        fields: [ContactField.displayName, ContactField.phoneNumbers],
      );
      if (!mounted) return;
      _showContactsPicker(contacts, isLimited: status.isLimited);
      return;
    }

    if (!mounted) return;

    if (status.isPermanentlyDenied) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '연락처 접근 권한 필요',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  '연락처 가져오기를 사용하려면 설정에서 연락처 접근을 허용해주세요.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('취소',
                            style: TextStyle(color: Colors.black54, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: ColorAssset.mainColor,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          openAppSettings();
                        },
                        child: const Text('설정으로 이동',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showUniqueSnackBar(
        const SnackBar(content: Text('연락처 접근 권한이 필요합니다')),
      );
    }
  }

  void _showContactsPicker(List<Contact> contacts, {bool isLimited = false}) {
    final searchController = TextEditingController();
    List<Contact> filtered = List.from(contacts);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '연락처 선택',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    if (isLimited) ...[
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          showDialog(
                            context: context,
                            builder: (dCtx) => AlertDialog(
                              backgroundColor: Colors.white,
                              title: const Text('모든 연락처 허용'),
                              content: const Text('설정 > 개인 정보 보호 > 연락처에서\n앱의 접근을 "모두 허용"으로 변경하면\n전체 연락처를 불러올 수 있습니다.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dCtx),
                                  child: const Text('취소'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dCtx);
                                    openAppSettings();
                                  },
                                  child: Text('설정 열기', style: TextStyle(color: ColorAssset.mainColor)),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: ColorAssset.mainColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.add_circle_outline, size: 16, color: ColorAssset.mainColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '더 많은 연락처 허용하기',
                                  style: TextStyle(fontSize: 13, color: ColorAssset.mainColor, fontWeight: FontWeight.w500),
                                ),
                              ),
                              Icon(Icons.chevron_right, size: 16, color: ColorAssset.mainColor),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: '이름 또는 번호 검색',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey.shade400),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (q) {
                          setSheetState(() {
                            filtered = contacts.where((c) {
                              final name = c.displayName.toLowerCase();
                              final phone = c.phones
                                  .map((p) => _digitsOnly(p.number))
                                  .join();
                              return name.contains(q.toLowerCase()) ||
                                  phone.contains(q);
                            }).toList();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                '연락처가 없습니다',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filtered.length,
                              itemBuilder: (_, i) {
                                final c = filtered[i];
                                final rawPhone = c.phones.isNotEmpty
                                    ? c.phones.first.number
                                    : '';
                                final digits = _digitsOnly(rawPhone);
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 2),
                                  leading: CircleAvatar(
                                    radius: 20,
                                    backgroundColor:
                                        ColorAssset.mainColor.withValues(alpha: 0.12),
                                    child: Text(
                                      c.displayName.isNotEmpty
                                          ? c.displayName[0]
                                          : '?',
                                      style: TextStyle(
                                        color: ColorAssset.mainColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    c.displayName,
                                    style: const TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: rawPhone.isNotEmpty
                                      ? Text(
                                          rawPhone,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade500),
                                        )
                                      : null,
                                  onTap: rawPhone.isEmpty
                                      ? null
                                      : () {
                                          Navigator.pop(ctx);
                                          _setRecipient(c.displayName, digits);
                                        },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showPhoneInputDialog() {
    final phoneController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '번호로 추가',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      autofocus: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                        _PhoneHyphenFormatter(),
                      ],
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: '010-0000-0000',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        errorText: errorText,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: ColorAssset.mainColor, width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                      ),
                      onChanged: (_) {
                        if (errorText != null) {
                          setDialogState(() => errorText = null);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('취소',
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 15)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: ColorAssset.mainColor,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              final digits =
                                  _digitsOnly(phoneController.text.trim());
                              if (!_isValidPhone(digits)) {
                                setDialogState(() =>
                                    errorText = '010으로 시작하는 11자리를 입력해주세요');
                                return;
                              }
                              Navigator.pop(ctx);
                              _setRecipient('', digits);
                            },
                            child: const Text('추가',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('받는 분', style: PaymentUiTokens.sectionTitle),
        const SizedBox(height: 12),
        if (_phone == null) ...[
          _ReceiverButton(
            icon: Icons.contacts_outlined,
            label: '연락처 가져오기',
            onTap: _pickFromContacts,
          ),
          const SizedBox(height: 8),
          _ReceiverButton(
            icon: Icons.dialpad_outlined,
            label: '번호로 추가',
            onTap: _showPhoneInputDialog,
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      ColorAssset.mainColor.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.person_outline,
                    size: 18,
                    color: ColorAssset.mainColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_name != null && _name!.isNotEmpty)
                        Text(
                          _name!,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      Text(
                        _formatPhone(_phone!),
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _clearRecipient,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close,
                        size: 14, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),
        const Text(
          '기프티콘은 카카오톡으로 전달됩니다.',
          style: TextStyle(fontSize: 13, color: PaymentUiTokens.captionGrey),
        ),
      ],
    );
  }
}

class _ReceiverButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ReceiverButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneHyphenFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 7) buffer.write('-');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
