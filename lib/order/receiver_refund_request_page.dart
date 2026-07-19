import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/api/receiver_refund_request.dart';
import 'package:cafeplatform/utils/account_number_formatter.dart';
import 'package:cafeplatform/widget/bank_selector_sheet.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';

class ReceiverRefundRequestPage extends StatefulWidget {
  const ReceiverRefundRequestPage({super.key, required this.orderId});

  final int orderId;

  @override
  State<ReceiverRefundRequestPage> createState() =>
      _ReceiverRefundRequestPageState();
}

class _ReceiverRefundRequestPageState
    extends State<ReceiverRefundRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _accountController = TextEditingController();
  final _reasonController = TextEditingController();

  String _selectedBankName = "은행선택";
  String _selectedBankCode = '';
  bool _isSubmitting = false;

  final _inputDecoration = InputDecoration(
    hintStyle: TextStyle(
      fontSize: 14,
      color: Colors.grey[400],
    ),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE6E6E6), width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE6E6E6), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: ColorAssset.mainColor, width: 1.2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );

  @override
  void dispose() {
    _nameController.dispose();
    _accountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  void _showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBankCode.isEmpty) {
      _showToast("은행을 선택해주세요.");
      return;
    }
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final body = ReceiverRefundRequest(
      receiverAccount: ReceiverAccount(
        accountHolder: _nameController.text.trim(),
        bankCode: _selectedBankCode,
        bankName: _selectedBankName,
        accountNumber: _accountController.text.replaceAll('-', ''),
      ),
      reason: _reasonController.text.trim().isEmpty
          ? null
          : _reasonController.text.trim(),
    );

    try {
      await Api().client.requestReceiverRefund(widget.orderId, body);
      _showToast("환불 신청이 접수되었습니다.");
      if (mounted) Navigator.pop(context, true);
    } on DioException catch (e) {
      String errorMessage = "환불 신청 중 오류가 발생했습니다.";
      if (e.response != null) {
        final serverDetail = e.response?.data is Map
            ? e.response?.data['detail'] as String?
            : null;
        if (serverDetail != null && serverDetail.isNotEmpty) {
          errorMessage = serverDetail;
        }
      } else {
        errorMessage = "네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요.";
      }
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showToast(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showToast("환불 신청 중 오류가 발생했습니다.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const CommonAppBar(title: "환불 신청"),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "환불 시 구매 금액의 90%가 환불됩니다.\n"
                          "환불은 매주 화요일 일괄 처리됩니다.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildLabel("예금주"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration.copyWith(
                          hintText: "예금주명을 입력해주세요",
                        ),
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '예금주명을 입력해주세요';
                          }
                          if (value.trim().length < 2) {
                            return '예금주명은 2자 이상 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      _buildLabel("은행선택"),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          showBankSelectorSheet(
                            context,
                            onSelected: (name, code) {
                              setState(() {
                                _selectedBankName = name;
                                _selectedBankCode = code;
                                _accountController.clear();
                              });
                            },
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _selectedBankName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _selectedBankName == "은행선택"
                                      ? Colors.grey[400]
                                      : Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildLabel("계좌번호"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _accountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          AccountNumberFormatter(bankCode: _selectedBankCode),
                          LengthLimitingTextInputFormatter(19),
                        ],
                        decoration: _inputDecoration.copyWith(
                          hintText: _selectedBankCode.isEmpty
                              ? "은행 선택 후 입력해주세요"
                              : "계좌번호를 입력해주세요",
                        ),
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                        validator: (value) {
                          if (value == null || value.isEmpty) return '계좌번호를 입력해주세요';
                          final digits = value.replaceAll('-', '');
                          if (!RegExp(r'^\d{10,14}$').hasMatch(digits)) {
                            return '계좌번호는 10~14자리 숫자입니다';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      _buildLabel("환불 사유 (선택)"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 3,
                        maxLength: 500,
                        decoration: _inputDecoration.copyWith(
                          hintText: "환불 사유를 입력해주세요",
                        ),
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorAssset.mainColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '신청하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
