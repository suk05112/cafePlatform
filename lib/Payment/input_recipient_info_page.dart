import 'package:flutter/material.dart';
import 'package:cafeplatform/Payment/success_payment_page.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/Payment/CommonPaymentWidget.dart';

class InputRecipientInfoPage extends StatefulWidget {
  const InputRecipientInfoPage({super.key});

  @override
  State<InputRecipientInfoPage> createState() => _InputRecipientInfoPagetate();
}

class _InputRecipientInfoPagetate extends State<InputRecipientInfoPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _phoneNumber = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  /// 한국 전화번호를 국제 형식으로 변환 (01012345678 -> +821012345678)
  static String convertToInternationalFormat(String phoneNumber) {
    // 하이픈, 공백 등 모든 비숫자 제거
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    String internationalFormat;

    // 첫 번째 0을 제거하고 82를 앞에 추가
    if (digitsOnly.startsWith('0')) {
      internationalFormat = '82${digitsOnly.substring(1)}';
    }
    // 이미 82로 시작하는 경우 그대로 사용
    else if (digitsOnly.startsWith('82')) {
      internationalFormat = digitsOnly;
    }
    // 그 외의 경우 82를 앞에 추가
    else {
      internationalFormat = '82$digitsOnly';
    }

    // + 기호 추가
    return '+$internationalFormat';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 44,
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "선물 정보 입력",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "선물하기",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "받을 분의 전화번호를 입력해주세요",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "기프티콘은 카카오톡(문자)로 전달됩니다.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              // 상품 정보 카드
              CommonPaymentWidget.getGiftInfo(),
              const SizedBox(height: 24),

              const Text(
                "받는 분 정보",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "전화번호",
                  hintText: "받을 분의 전화번호를 입력해주세요 (예: 01012345678)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _phoneNumber = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "메시지를 입력해주세요 (생략 가능)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "결제 수단",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              PaymentMehtod(),
              const SizedBox(height: 24),

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
                    '다음',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    // 전화번호 유효성 검증
                    if (_phoneNumber.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('받을 분의 전화번호를 입력해주세요'),
                        ),
                      );
                      return;
                    }

                    // 전화번호 형식 검증 (숫자만 추출)
                    final digitsOnly =
                        _phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
                    if (digitsOnly.length != 10 && digitsOnly.length != 11) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('올바른 전화번호를 입력해주세요 (10-11자리)'),
                        ),
                      );
                      return;
                    }

                    // 전화번호를 국제 형식으로 변환 (01012345678 -> 821012345678)
                    final internationalPhone =
                        convertToInternationalFormat(_phoneNumber);
                    print('전화번호 변환: $_phoneNumber -> $internationalPhone');

                    // TODO: 서버에 전송할 때 internationalPhone 사용
                    // 다음 화면으로 이동 시 전화번호 전달 필요 시 여기에 추가

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SuccessPaymentPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget PaymentMehtod() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('신용/체크카드'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SuccessPaymentPage()),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('카카오페이'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SuccessPaymentPage()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('네이버페이'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SuccessPaymentPage()),
              );
            },
          ),
        ),
      ],
    );
  }
}
