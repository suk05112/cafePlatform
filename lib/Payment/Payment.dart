// import 'package:bootpay/bootpay.dart';
// import 'package:bootpay/model/payload.dart';
// import 'package:bootpay/model/user.dart' as bt;
// import 'package:bootpay/model/extra.dart' as bt_ex;
// import 'package:bootpay/model/item.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:cafeplatform/Payment/CompletePayment.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/api/gifticon_response.dart';
import 'package:cafeplatform/model/gifticon.dart';
import 'package:cafeplatform/model/menu.dart';
import 'package:cafeplatform/model/user.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:cafeplatform/terms/payment_terms.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_info.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';
import 'package:tosspayments_widget_sdk_flutter/payment_widget.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/agreement.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/payment_method.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:cafeplatform/utils/number_formatter.dart';

class Payment extends StatefulWidget {
  const Payment({super.key, required this.type, required this.menu});

  final int type;
  final Menu menu; // 메뉴 객체를 저장할 필드 추가

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String receiver = "";
  String receiverPhoneNumber = "";

  // 토스페이먼츠 위젯 관련 상태
  late PaymentWidget _paymentWidget;
  PaymentMethodWidgetControl? _paymentMethodWidgetControl;
  AgreementWidgetControl? _agreementWidgetControl;

  // 주문 정보 저장
  int? _orderId;

  @override
  void initState() {
    super.initState();

    // PaymentWidget 초기화
    // TODO: 실제 clientKey와 customerKey로 교체 필요
    _paymentWidget = PaymentWidget(
      clientKey: "test_gck_docs_Ovk5rk1EwkEbP0W43n07xlzm", // 테스트 키
      customerKey: "zG5XLcHhA7c3tuJsV_H3j", // 테스트 키
    );

    // 결제수단 위젯 렌더링
    _paymentWidget
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
      }
    }).catchError((error) {
      print("결제수단 위젯 렌더링 오류: $error");
    });

    // 약관 위젯 렌더링
    _paymentWidget
        .renderAgreement(selector: 'payment-agreement')
        .then((control) {
      if (mounted) {
        setState(() {
          _agreementWidgetControl = control;
        });
      }
    }).catchError((error) {
      print("약관 위젯 렌더링 오류: $error");
    });
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
      child: Scaffold(
        appBar: const CommonAppBar(title: "결제하기"),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 주문정보
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("주문정보",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 12),
                            _buildCompactGiftInfo(),
                          ],
                        ),
                      ),
                      Container(
                          height: 14,
                          width: double.infinity,
                          color: Color(0xFFF5F6FA)),

                      /// 받는 분 정보(선물하기일 때 표시)
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
                            color: Color(0xFFF5F6FA)),
                      ],

                      /// 결제수단
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("결제 수단",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 12),
                            PaymentMethodWidget(
                              paymentWidget: _paymentWidget,
                              selector: 'payment-methods',
                            ),
                            const SizedBox(height: 12),
                            AgreementWidget(
                              paymentWidget: _paymentWidget,
                              selector: 'payment-agreement',
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
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 10),
                            _priceRow("총 상품금액", price),
                            const SizedBox(height: 5),
                            _priceRow("할인금액", discount),
                            const Divider(),
                            _priceRow("최종 결제금액", finalPrice, bold: true),
                          ],
                        ),
                      ),
                      Container(
                          height: 14,
                          width: double.infinity,
                          color: Color(0xFFF5F6FA)),
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
    );
  }

  /// 단일 금액 Row
  Widget _priceRow(String label, int amount, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
        Text("${amount.toString()}원",
            style: TextStyle(
                fontSize: 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.w400)),
      ],
    );
  }

  // 기존 CommonPaymentWidget.getGiftInfo()와 동일한 정보이되,
  // 결제 화면에서는 더 작게, 설명 없이 보여주는 컴팩트 카드
  Widget _buildCompactGiftInfo() {
    final menu = widget.menu;
    return Container(
      // padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.03),
        //     blurRadius: 8,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: Image.network(
                menu.menu_image_url ?? "",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/coffee.jpeg',
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  menu.name ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${menu.price}원",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          child: Text(
            '${widget.menu.price}원 결제하기',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          onPressed: () async {
            // 키보드 닫기
            FocusScope.of(context).unfocus();

            // 약관 동의 확인
            if (_agreementWidgetControl == null ||
                _paymentMethodWidgetControl == null) {
              _showToast('결제위젯이 준비되지 않았습니다.');
              return;
            }

            final agreement =
                await _agreementWidgetControl?.getAgreementStatus();
            if (agreement?.agreedRequiredTerms != true) {
              _showToast('필수 약관에 모두 동의해주세요.');
              return;
            }

            // 선택된 결제수단 확인
            final selectedPaymentMethod =
                await _paymentMethodWidgetControl?.getSelectedPaymentMethod();

            if (selectedPaymentMethod == null) {
              _showToast('결제수단을 선택해주세요.');
              return;
            }

            // 선택된 결제수단 정보 출력 (디버깅용)
            print('선택된 결제수단: ${selectedPaymentMethod.method}');
            print('결제 타입: ${selectedPaymentMethod.type}');
            if (selectedPaymentMethod.easyPay != null) {
              print('간편결제: ${selectedPaymentMethod.easyPay?.provider}');
            }

            // 결제 수단에 따라 payment 값 설정
            String paymentValue;
            final method = selectedPaymentMethod.method?.toLowerCase() ?? '';
            if (method == 'card') {
              paymentValue = '카드';
            } else if (selectedPaymentMethod.easyPay != null) {
              // 간편결제인 경우 provider 값 사용
              paymentValue = selectedPaymentMethod.easyPay!.provider ?? '간편결제';
            } else {
              // 기본값
              paymentValue = selectedPaymentMethod.method ?? '기타';
            }
            print('결제 수단: $paymentValue');

            // 선물하기인 경우 받는 분 정보 검증
            if (widget.type == 2) {
              if (receiver.trim().isEmpty) {
                _showToast('받는 분의 이름을 입력해주세요.');
                return;
              }
              if (receiverPhoneNumber.trim().isEmpty) {
                _showToast('받는 분의 전화번호를 입력해주세요.');
                return;
              }
              // 전화번호 형식 검증 (3-4-4 형식: 010-1234-5678)
              final phoneNumber =
                  receiverPhoneNumber.replaceAll(RegExp(r'[^\d]'), '');
              // 숫자만 추출하여 10-11자리인지 확인
              if (phoneNumber.length != 10 && phoneNumber.length != 11) {
                _showToast('올바른 전화번호를 입력해주세요. (10-11자리)');
                return;
              }
              // 3-4-4 형식 검증 (하이픈 포함 13자리 또는 12자리)
              final phonePattern = RegExp(r'^010-\d{4}-\d{4}$');
              if (!phonePattern.hasMatch(receiverPhoneNumber)) {
                _showToast('전화번호 형식이 올바르지 않습니다. (예: 010-1234-5678)');
                return;
              }
            }

            // 1단계: gifticon, order 정보 등록 (결제 전)
            final user = Provider.of<UserProvider>(context, listen: false).user;
            if (user == null) {
              _showToast('로그인이 필요합니다.');
              return;
            }

            Gifticon gifticon = Gifticon();
            print('gifticon: $gifticon');
            gifticon.store_id = widget.menu.store_id;
            gifticon.type = widget.type;
            gifticon.name = widget.menu.name ?? "";
            gifticon.sender = user.name;
            gifticon.receiver = receiver;
            gifticon.receiver_phone_number = receiverPhoneNumber;
            gifticon.payment = paymentValue;
            gifticon.menu_id = widget.menu.menu_id;
            gifticon.total_price = widget.menu.price;
            gifticon.paymentKey = null; // 결제 전이므로 NULL
            gifticon.order_id = 0;

            try {
              // 정보 등록 API 호출
              final registrationResponse = await Api().client.purchaseGifticon(
                    user.user_id,
                    gifticon,
                  );

              print(
                  "정보 등록 완료: order_id=${registrationResponse.order_id}, gifticon_id=${registrationResponse.gifticon_id}, order_no=${registrationResponse.order_no}");

              // order_id 저장
              setState(() {
                _orderId = registrationResponse.order_id;
              });

              // gifticon 객체에 ID 업데이트
              gifticon.order_id = registrationResponse.order_id;
              gifticon.gifticon_id = registrationResponse.gifticon_id;

              // 주문 ID 생성 (토스페이먼츠용 - 서버에서 받은 order_no 사용)
              final orderName = widget.type == 1
                  ? widget.menu.name
                  : '${widget.menu.name} (선물)';

              // 2단계: 토스페이먼츠 결제 요청
              final paymentResult = await _paymentWidget.requestPayment(
                paymentInfo: PaymentInfo(
                  orderId: registrationResponse.order_no,
                  orderName: orderName ?? '',
                ),
              );

              if (paymentResult.success != null) {
                // 결제 성공 처리
                print("결제 성공: ${paymentResult.success}");
                await _handlePaymentSuccess(
                  paymentKey: paymentResult.success?.paymentKey ?? "",
                  orderId: registrationResponse.order_id,
                  gifticon: gifticon,
                );
              } else if (paymentResult.fail != null) {
                // 결제 실패 처리
                print("결제 실패: ${paymentResult.fail}");
                await _handlePaymentFailure(
                  orderId: registrationResponse.order_id,
                );
                _showToast('결제에 실패했습니다. 다시 시도해주세요.');
              }
            } on DioException catch (e) {
              print("정보 등록 실패: $e");
              _showToast('주문 정보 등록에 실패했습니다. 다시 시도해주세요.');
            } catch (e) {
              print("결제 오류: $e");
              if (_orderId != null) {
                // 정보 등록은 성공했지만 결제 중 오류 발생
                await _handlePaymentFailure(
                  orderId: _orderId!,
                );
              }
              _showToast('결제 중 오류가 발생했습니다.');
            }
          },
        ),
      ),
    );
  }

  Future<void> _handlePaymentSuccess({
    required String paymentKey,
    required int orderId,
    required Gifticon gifticon,
  }) async {
    // 3단계: 결제 결과 서버에 전달
    bool success = false;
    int retryCount = 0;
    const maxRetries = 3;

    while (!success && retryCount < maxRetries) {
      try {
        final paymentResultRequest = PaymentResultRequest(
          order_id: orderId,
          payment_key: paymentKey,
          is_success: true,
        );

        await Api().client.sendPaymentResult(paymentResultRequest);
        print("결제 결과 서버 전달 완료: order_id=$orderId");
        success = true;

        // gifticon 객체에 payment_key 업데이트
        gifticon.paymentKey = paymentKey;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompletePayment(
              giftType: widget.type,
              gifticon: gifticon,
            ),
          ),
        );
        return;
      } on DioException catch (e) {
        retryCount++;
        print("결제 결과 전달 실패 (시도 $retryCount/$maxRetries): $e");

        if (retryCount >= maxRetries) {
          // 최대 재시도 횟수 초과
          _handleServerRegistrationFailure(
            paymentKey: paymentKey,
            gifticon: gifticon,
            error: e,
          );
          return;
        }

        // 재시도 전 대기 (지수 백오프)
        await Future.delayed(Duration(seconds: retryCount));
      } catch (e) {
        retryCount++;
        print("결제 결과 전달 실패 (시도 $retryCount/$maxRetries): $e");

        if (retryCount >= maxRetries) {
          // 최대 재시도 횟수 초과
          _handleServerRegistrationFailure(
            paymentKey: paymentKey,
            gifticon: gifticon,
            error: e,
          );
          return;
        }

        // 재시도 전 대기
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
  }

  Future<void> _handlePaymentFailure({
    required int orderId,
  }) async {
    // 결제 실패 결과 서버에 전달 (is_success가 false면 payment_key는 null)
    try {
      final paymentResultRequest = PaymentResultRequest(
        order_id: orderId,
        payment_key: null, // 결제 실패 시 payment_key는 null
        is_success: false,
      );

      await Api().client.sendPaymentResult(paymentResultRequest);
      print("결제 실패 결과 서버 전달 완료: order_id=$orderId");
    } catch (e) {
      print("결제 실패 결과 전달 실패: $e");
    }
  }

  void _handleServerRegistrationFailure({
    required String paymentKey,
    required Gifticon gifticon,
    required dynamic error,
  }) {
    String errorTitle = "서버 등록 실패";
    String errorDetail = "";
    IconData errorIcon = Icons.error_outline;
    Color errorColor = Colors.orange;

    if (error is DioException) {
      if (error.response != null) {
        final statusCode = error.response!.statusCode;
        if (statusCode == 500) {
          errorTitle = "서버 오류";
          errorDetail = "서버에 일시적인 문제가 발생했습니다.\n잠시 후 다시 시도해주세요.";
          errorIcon = Icons.cloud_off_outlined;
          errorColor = Colors.red;
        } else if (statusCode == 400) {
          errorTitle = "요청 오류";
          errorDetail = "잘못된 요청입니다.\n고객센터로 문의해주세요.";
          errorIcon = Icons.info_outline;
          errorColor = Colors.orange;
        } else if (statusCode == 401) {
          errorTitle = "인증 실패";
          errorDetail = "인증에 실패했습니다.\n다시 로그인해주세요.";
          errorIcon = Icons.lock_outline;
          errorColor = Colors.orange;
        } else {
          errorTitle = "서버 오류";
          errorDetail = "서버 오류가 발생했습니다.\n(오류 코드: $statusCode)";
          errorIcon = Icons.error_outline;
          errorColor = Colors.red;
        }
      } else {
        errorTitle = "네트워크 오류";
        errorDetail = "인터넷 연결에 문제가 있습니다.\n연결을 확인해주세요.";
        errorIcon = Icons.wifi_off;
        errorColor = Colors.orange;
      }
    } else {
      errorTitle = "알 수 없는 오류";
      errorDetail = "예기치 않은 오류가 발생했습니다.";
      errorIcon = Icons.error_outline;
      errorColor = Colors.red;
    }

    // 결제 정보를 로컬에 저장 (나중에 재시도용)
    _saveFailedPaymentInfo(paymentKey, gifticon);

    _showBeautifulErrorDialog(
      title: errorTitle,
      detail: errorDetail,
      icon: errorIcon,
      iconColor: errorColor,
      paymentKey: paymentKey,
    );
  }

  void _showBeautifulErrorDialog({
    required String title,
    required String detail,
    required IconData icon,
    required Color iconColor,
    required String paymentKey,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 아이콘
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 40,
                    color: iconColor,
                  ),
                ),
                SizedBox(height: 20),

                // 제목
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),

                // 설명
                Text(
                  "결제는 완료되었지만\n서버에 등록하지 못했습니다.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),

                // 상세 메시지
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    detail,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),

                // 결제 정보 안내
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue[200]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.blue[700],
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "결제 정보는 안전하게 보관되었습니다.\n고객센터로 문의하시면 빠르게 처리해드리겠습니다.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[900],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),

                // 결제 키 (작은 글씨)
                Text(
                  "결제 키: ${paymentKey.substring(0, 12)}...",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontFamily: 'monospace',
                  ),
                ),
                SizedBox(height: 24),

                // 확인 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // 다이얼로그 닫기
                      Navigator.pop(context); // 결제 페이지 닫기
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "확인",
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

  Future<void> _saveFailedPaymentInfo(
      String paymentKey, Gifticon gifticon) async {
    // SharedPreferences에 실패한 결제 정보 저장 (나중에 재시도하거나 고객센터 문의 시 사용)
    try {
      final prefs = await SharedPreferences.getInstance();
      final failedPayments = prefs.getStringList('failed_payments') ?? [];
      final paymentInfo = {
        'paymentKey': paymentKey,
        'timestamp': DateTime.now().toIso8601String(),
        'menu_id': gifticon.menu_id.toString(),
        'store_id': gifticon.store_id.toString(),
        'price': gifticon.total_price.toString(),
        'receiver': gifticon.receiver,
        'receiver_phone': gifticon.receiver_phone_number,
      };
      failedPayments.add(paymentInfo.toString());
      await prefs.setStringList('failed_payments', failedPayments);
      print("실패한 결제 정보 저장 완료: $paymentKey");
    } catch (e) {
      print("실패한 결제 정보 저장 실패: $e");
    }
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
    final FeedTemplate defaultFeed = FeedTemplate(
      content: Content(
        title: '${gifticon.sender}님으로부터 선물이 도착했어요!',
        description: '${gifticon.sender}님이 선물을 보냈어요. 앱에서 바로 확인해보세요!',
        // imageUrl: Uri.parse(gifticon.),
        link: Link(
            webUrl: Uri.parse('https://developers.kakao.com'),
            mobileWebUrl: Uri.parse('https://developers.kakao.com')),
      ),
      itemContent: ItemContent(
        profileText: 'Gifnut',
        profileImageUrl: Uri.parse(
            'https://mud-kage.kakao.com/dn/Q2iNx/btqgeRgV54P/VLdBs9cvyn8BJXB3o7N8UK/kakaolink40_original.png'),
        titleImageUrl: Uri.parse(
            'https://mud-kage.kakao.com/dn/Q2iNx/btqgeRgV54P/VLdBs9cvyn8BJXB3o7N8UK/kakaolink40_original.png'),
        titleImageText: gifticon.name,
        titleImageCategory: gifticon.store_name,
      ),
      buttons: [
        Button(
          title: '사용방법',
          link: Link(
            webUrl: Uri.parse(
                'https://imminent-carob-33e.notion.site/198b720032c3807ca732fbd4445cc614'),
            mobileWebUrl: Uri.parse(
                'https://imminent-carob-33e.notion.site/198b720032c3807ca732fbd4445cc614'),
          ),
        ),
        Button(
          title: '선물받기',
          link: Link(
            // webUrl: Uri.parse('https: //developers.kakao.com'),
            // mobileWebUrl: Uri.parse('https: //developers.kakao.com'),
            androidExecutionParams: {'gifticon_id': '${gifticon.gifticon_id}'},
            iosExecutionParams: {'gifticon_id': '${gifticon.gifticon_id}'},
          ),
        ),
      ],
    );

    // 카카오톡 실행 가능 여부 확인
    bool isKakaoTalkSharingAvailable =
        await ShareClient.instance.isKakaoTalkSharingAvailable();

    if (isKakaoTalkSharingAvailable) {
      try {
        Uri uri =
            await ShareClient.instance.shareDefault(template: defaultFeed);
        await ShareClient.instance.launchKakaoTalk(uri);
        print('카카오톡 공유 완료');
      } catch (error) {
        print('카카오톡 공유 실패 $error');
      }
    } else {
      try {
        Uri shareUrl = await WebSharerClient.instance
            .makeDefaultUrl(template: defaultFeed);
        await launchBrowserTab(shareUrl, popupOpen: true);
      } catch (error) {
        print('카카오톡 공유 실패 $error');
      }
    }
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        TextField(
          controller: _receiverController,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            labelText: "받는 분 이름 *",
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
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
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
