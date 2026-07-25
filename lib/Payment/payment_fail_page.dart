import 'package:flutter/material.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/store_page.dart';
import 'package:cafeplatform/main.dart';
import 'package:cafeplatform/utils/business_info_helper.dart';

class PaymentFailPage extends StatefulWidget {
  const PaymentFailPage({super.key, this.storeId, this.storeName});

  /// 확인 버튼 클릭 시 이동할 매장 상세 정보. storeId가 없으면 홈으로 이동.
  final int? storeId;
  final String? storeName;

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

  /// 결제 화면까지 쌓인 스택(진입 경로에 따라 깊이가 다름)을 모두 제거하고
  /// 매장 상세 화면으로 새로 이동. storeId가 없으면 홈으로 이동.
  void _returnToStore() {
    if (widget.storeId != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => StorePage(
            storeId: widget.storeId!,
            storeName: widget.storeName ?? '',
          ),
        ),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TabPage()),
        (route) => false,
      );
    }
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
                    onPressed: _returnToStore,
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
