import 'package:flutter/material.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/utils/business_info_helper.dart';

class PaymentFailPage extends StatefulWidget {
  const PaymentFailPage({super.key});

  @override
  State<PaymentFailPage> createState() => _PaymentFailPageState();
}

class _PaymentFailPageState extends State<PaymentFailPage> {
  String? _customerServicePhone;

  @override
  void initState() {
    super.initState();
    _loadCustomerServicePhone();
  }

  Future<void> _loadCustomerServicePhone() async {
    try {
      final info = await BusinessInfoHelper.getBusinessInfo();
      if (mounted) {
        setState(() {
          _customerServicePhone = info.telephone;
        });
      }
    } catch (_) {}
  }

  /// 이 페이지(실패 안내) + Payment + SelectGiftPage 3단계를 pop하여
  /// 메뉴 상세 화면(진입 경로 무관)으로 리턴
  void _returnToMenuDetail() {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pop();
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Icon(
                      Icons.credit_card_off,
                      size: 80,
                      color: Colors.red[400],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  "결제를 실패했어요",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "•  주문내역과 결제수단을 확인 후 재시도 해보시기 바랍니다.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _customerServicePhone != null
                            ? "•  지속적으로 결제가 이루어지지 않는 경우 고객상담실로 문의 주시기 바랍니다. ($_customerServicePhone)"
                            : "•  지속적으로 결제가 이루어지지 않는 경우 고객상담실로 문의 주시기 바랍니다.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      foregroundColor: Colors.white,
                      backgroundColor: ColorAssset.mainColor,
                      elevation: 0,
                    ),
                    onPressed: _returnToMenuDetail,
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
