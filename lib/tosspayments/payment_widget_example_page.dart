import 'package:flutter/material.dart';
import 'package:cafeplatform/tosspayments/toss_compnents.dart';
import 'package:cafeplatform/tosspayments/widget_home.dart';
import 'package:tosspayments_widget_sdk_flutter/model/agreement_status.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_info.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';
import 'package:tosspayments_widget_sdk_flutter/payment_widget.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/agreement.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/payment_method.dart';

import 'package:fluttertoast/fluttertoast.dart';

class PaymentWidgetExamplePage extends StatefulWidget {
  final UIState info;
  final PaymentInfo data;

  const PaymentWidgetExamplePage(
      {super.key, required this.data, required this.info});

  @override
  State<PaymentWidgetExamplePage> createState() {
    return _PaymentWidgetExamplePageState();
  }
}

class _PaymentWidgetExamplePageState extends State<PaymentWidgetExamplePage> {
  late PaymentWidget _paymentWidget;
  PaymentMethodWidgetControl? _paymentMethodWidgetControl;
  AgreementWidgetControl? _agreementWidgetControl;
  AgreementStatus? agreementStatus;

  @override
  void initState() {
    super.initState();

    _paymentWidget = PaymentWidget(
      clientKey: "test_gck_docs_Ovk5rk1EwkEbP0W43n07xlzm",
      customerKey: "zG5XLcHhA7c3tuJsV_H3j",
      // 결제위젯에 브랜드페이 추가하기
      // paymentWidgetOptions: PaymentWidgetOptions(brandPayOption: BrandPayOption("리다이렉트 URL")) // Access Token 발급에 사용되는 리다이렉트 URL
    );

    _paymentWidget
        .renderPaymentMethods(
            selector: 'methods',
            amount: Amount(value: 300, currency: Currency.KRW, country: "KR"),
            options: RenderPaymentMethodsOptions(variantKey: "DEFAULT"))
        .then((control) {
      _paymentMethodWidgetControl = control;
    });

    _paymentWidget.renderAgreement(selector: 'agreement').then((control) {
      _agreementWidgetControl = control;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(children: [
      Expanded(
          child: ListView(children: [
        PaymentMethodWidget(
          paymentWidget: _paymentWidget,
          selector: 'methods',
        ),
        AgreementWidget(paymentWidget: _paymentWidget, selector: 'agreement'),
        ElevatedButton(
            onPressed: () async {
              if (_agreementWidgetControl == null ||
                  _paymentMethodWidgetControl == null) {
                toast(context, 'requestPayment', '결제위젯이 렌더링되지 않았습니다.');
                return;
              }

              final agreement =
                  await _agreementWidgetControl?.getAgreementStatus();
              if (agreement?.agreedRequiredTerms != true) {
                if (!mounted) return;
                toast(context, 'requestPayment', '필수 약관에 모두 동의하지 않았습니다.');
                return;
              }

              final paymentResult = await _paymentWidget.requestPayment(
                  paymentInfo: const PaymentInfo(
                      orderId: '7x9iD03RznxZxiKVjZ8db',
                      orderName: '토스 티셔츠 외 2건'));
              if (paymentResult.success != null) {
                // 결제 성공 처리
              } else if (paymentResult.fail != null) {
                // 결제 실패 처리
              }
            },
            child: const Text('결제하기')),
        ElevatedButton(
            onPressed: () async {
              final selectedPaymentMethod =
                  await _paymentMethodWidgetControl?.getSelectedPaymentMethod();
            },
            child: const Text('선택한 결제수단 출력')),
        const SizedBox(height: 20),
        BlueButton(
          onPressed: () async {
            /// [AgreementWidgetControl]을 이용해 고객의 필수 약관 동의 상태를 구합니다.
            var status = await _agreementWidgetControl?.getAgreementStatus();
            setState(() {
              agreementStatus = status;
            });
          },
          text: '(클릭시 갱신) 약관 동의 상태 : ${agreementStatus?.toString()}',
        ),
        ElevatedButton(
            onPressed: () async {
              final agreementStatus =
                  await _agreementWidgetControl?.getAgreementStatus();
            },
            child: const Text('약관 동의 상태 출력')),
        ElevatedButton(
            onPressed: () async {
              await _paymentMethodWidgetControl?.updateAmount(amount: 300);
            },
            child: const Text('결제 금액 변경'))
      ]))
    ])));
  }
}

/*

class _PaymentWidgetExamplePageState extends State<PaymentWidgetExamplePage> {
  SelectedPaymentMethod? selectedPaymentMethod;
  AgreementStatus? agreementStatus;

  UIState get info => widget.info;

  PaymentInfo get data => widget.data;

  late PaymentWidget _paymentWidget;
  PaymentMethodWidgetControl? _paymentMethodWidgetControl;
  AgreementWidgetControl? _agreementWidgetControl;

  @override
  void initState() {
    super.initState();

    /// PaymentWidget 객체를 초기화합니다.
    _paymentWidget = PaymentWidget(
      // clientKey: info.clientKey,
      // customerKey: info.customerKey,
      clientKey: "test_gck_docs_Ovk5rk1EwkEbP0W43n07xlzm",
      customerKey: "zG5XLcHhA7c3tuJsV_H3j",
    );

    /// [renderPaymentMethods] 함수로 결제수단 위젯을 렌더링합니다.
    _paymentWidget
        .renderPaymentMethods(
            selector: 'methods',
            amount: Amount(
                value: info.amount,
                currency: info.currency,
                country: info.country),
            options: RenderPaymentMethodsOptions(
                variantKey: info.variantKeyMethod ?? ""))
        .then((control) {
      _paymentMethodWidgetControl = control;
    }, onError: (fail) {
      Get.offAndToNamed("/result", arguments: fail);
      return;
    });

    /// [renderAgreement] 함수로 약관 위젯을 렌더링합니다.
    _paymentWidget
        .renderAgreement(
            selector: 'agreement',
            options: RenderAgreementOptions(
                variantKey: info.variantKeyAgreement ?? ""))
        .then((control) {
      _agreementWidgetControl =
          control; // Future.then을 통해 _agreementWidgetControl을 초기화합니다.
    }, onError: (fail) {
      Get.offAndToNamed("/result", arguments: fail);
      return;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  /// UI 상에서 원하는 위치에 PaymentMethodWidget 위젯을 추가합니다.
                  PaymentMethodWidget(
                    paymentWidget: _paymentWidget,
                    selector: 'methods',
                    onCustomRequested: (key) {
                      toast(context, 'onCustomRequested', key);
                    },
                    onCustomPaymentMethodSelected: (key) {
                      toast(context, 'onCustomPaymentMethodSelected', key);
                    },
                    onCustomPaymentMethodUnselected: (key) {
                      toast(context, 'onCustomPaymentMethodUnselected', key);
                    },
                  ),
                  Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          BlueButton(
                            onPressed: () async {
                              /// [PaymentMethodWidgetControl] 이용해 현재 고객이 선택한 결제수단을 구합니다.
                              final selected = await _paymentMethodWidgetControl
                                  ?.getSelectedPaymentMethod();
                              setState(() {
                                selectedPaymentMethod = selected;
                              });
                            },
                            text:
                                '(클릭시 갱신) 선택한 결제수단 : ${selectedPaymentMethod?.method} ${selectedPaymentMethod?.easyPay?.provider ?? ''}',
                          ),
                          const SizedBox(height: 20),
                          BlueButton(
                            onPressed: () async {
                              /// [AgreementWidgetControl]을 이용해 고객의 필수 약관 동의 상태를 구합니다.
                              var status = await _agreementWidgetControl
                                  ?.getAgreementStatus();
                              setState(() {
                                agreementStatus = status;
                              });
                            },
                            text:
                                '(클릭시 갱신) 약관 동의 상태 : ${agreementStatus?.toString()}',
                          ),
                        ],
                      )),

                  /// UI 상에서 원하는 위치에 AgreementWidget 위젯을 추가합니다.
                  AgreementWidget(
                    paymentWidget: _paymentWidget,
                    selector: 'agreement',
                    onChange: (status) {
                      toast(context, 'agreed',
                          status.agreedRequiredTerms.toString());
                    },
                  ),
                ],
              ),
            ),
            Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                        child: BlueButton(
                            onPressed: () {
                              _showNumberInputDialog(context, (int newAmount) {
                                /// [PaymentMethodWidgetControl]을 이용해 결제 금액을 업데이트합니다.
                                _paymentMethodWidgetControl
                                    ?.updateAmount(amount: newAmount)
                                    .then((_) {
                                  toast(context, 'updateAmount',
                                      '결제 금액이 $newAmount원으로 변경되었습니다.');
                                });
                              });
                            },
                            text: '금액변경')),
                    const SizedBox(width: 20),
                    Expanded(
                        child: BlueButton(
                            onPressed: () async {
                              if (_agreementWidgetControl == null ||
                                  _paymentMethodWidgetControl == null) {
                                toast(context, 'requestPayment',
                                    '결제위젯이 렌더링되지 않았습니다.');
                                return;
                              }

                              final agreement = await _agreementWidgetControl
                                  ?.getAgreementStatus();
                              if (agreement?.agreedRequiredTerms != true) {
                                if (!mounted) return;
                                toast(context, 'requestPayment',
                                    '필수 약관에 모두 동의하지 않았습니다.');
                                return;
                              }

                              /// [requestPayment]를 통해 결제창으로 이동합니다.
                              final Result paymentResult = await _paymentWidget
                                  .requestPayment(paymentInfo: data);
                              if (paymentResult.success != null) {
                                Get.back(result: paymentResult.success);
                              } else if (paymentResult.fail != null) {
                                Get.to(() => const ResultPage(),
                                    arguments: paymentResult.fail);
                              }
                            },
                            text: '결제하기')),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

void _showNumberInputDialog(
  BuildContext context,
  void Function(int) onConfirm,
) {
  TextEditingController controller = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('변경할 금액 입력'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '숫자를 입력하세요'),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('취소'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('확인'),
            onPressed: () {
              String inputText = controller.text;
              if (inputText.isNotEmpty) {
                int? number = int.tryParse(inputText);
                if (number != null) {
                  onConfirm(number);
                  Navigator.of(context).pop();
                } else {
                  toast(context, 'updateAmount', '올바른 값을 입력해 주세요.');
                }
              } else {
                toast(context, 'updateAmount', '올바른 값을 입력해 주세요.');
              }
            },
          ),
        ],
      );
    },
  );
}

*/

void toast(BuildContext context, String title, String description) {
  Fluttertoast.showToast(
      msg: "$title : $description",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}
