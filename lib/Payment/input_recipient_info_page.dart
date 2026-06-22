import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:cafeplatform/Payment/success_payment_page.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/Payment/CommonPaymentWidget.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:cafeplatform/Extension/scaffold_messenger_extension.dart';

class Recipient {
  final String name;
  final String phone;
  const Recipient({required this.name, required this.phone});
}

class InputRecipientInfoPage extends StatefulWidget {
  const InputRecipientInfoPage({super.key});

  @override
  State<InputRecipientInfoPage> createState() => _InputRecipientInfoPageState();
}

class _InputRecipientInfoPageState extends State<InputRecipientInfoPage> {
  Recipient? _recipient;
  bool _giftToMyself = false;

  static String _digitsOnly(String phone) =>
      phone.replaceAll(RegExp(r'[^\d]'), '');

  static String convertToInternationalFormat(String phoneNumber) {
    final digits = _digitsOnly(phoneNumber);
    if (digits.startsWith('0')) return '+82${digits.substring(1)}';
    if (digits.startsWith('82')) return '+$digits';
    return '+82$digits';
  }

  bool _isValidPhone(String phone) {
    final d = _digitsOnly(phone);
    return d.length == 10 || d.length == 11;
  }

  void _setGiftToMyself(bool value) {
    final user = context.read<UserProvider>().user;
    setState(() {
      _giftToMyself = value;
      if (value && user != null) {
        _recipient = Recipient(
          name: user.name.isEmpty ? '나' : user.name,
          phone: user.phone_number,
        );
      } else if (!value) {
        _recipient = null;
      }
    });
  }

  Future<void> _pickFromContacts() async {
    final status = await Permission.contacts.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showUniqueSnackBar(
          const SnackBar(content: Text('연락처 접근 권한이 필요합니다')),
        );
      }
      return;
    }

    final contacts = await FastContacts.getAllContacts(
      fields: [ContactField.displayName, ContactField.phoneNumbers],
    );

    if (!mounted) return;
    _showContactsPicker(contacts);
  }

  void _showContactsPicker(List<Contact> contacts) {
    final searchController = TextEditingController();
    List<Contact> filtered = List.from(contacts);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '연락처 선택',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: '이름 또는 번호 검색',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
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
                          ? const Center(child: Text('연락처가 없습니다'))
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filtered.length,
                              itemBuilder: (_, i) {
                                final c = filtered[i];
                                final phone = c.phones.isNotEmpty
                                    ? c.phones.first.number
                                    : '';
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        ColorAssset.mainColor.withOpacity(0.15),
                                    child: Text(
                                      c.displayName.isNotEmpty
                                          ? c.displayName[0]
                                          : '?',
                                      style: TextStyle(
                                        color: ColorAssset.mainColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(c.displayName),
                                  subtitle: phone.isNotEmpty
                                      ? Text(phone)
                                      : null,
                                  onTap: phone.isEmpty
                                      ? null
                                      : () {
                                          Navigator.pop(ctx);
                                          setState(() {
                                            _giftToMyself = false;
                                            _recipient = Recipient(
                                              name: c.displayName,
                                              phone: _digitsOnly(phone),
                                            );
                                          });
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
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('번호로 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '이름 (선택)',
                  hintText: '이름을 입력해주세요',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: '전화번호',
                  hintText: '01012345678',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                final phone = phoneController.text.trim();
                if (!_isValidPhone(phone)) {
                  ScaffoldMessenger.of(context).showUniqueSnackBar(
                    const SnackBar(
                      content: Text('올바른 전화번호를 입력해주세요 (10-11자리)'),
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx);
                setState(() {
                  _giftToMyself = false;
                  _recipient = Recipient(
                    name: nameController.text.trim().isEmpty
                        ? phone
                        : nameController.text.trim(),
                    phone: phone,
                  );
                });
              },
              child: Text(
                '추가',
                style: TextStyle(color: ColorAssset.mainColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void _removeRecipient() {
    setState(() {
      _recipient = null;
      _giftToMyself = false;
    });
  }

  void _onNext() {
    if (_recipient == null) {
      ScaffoldMessenger.of(context).showUniqueSnackBar(
        const SnackBar(content: Text('받을 분을 추가해주세요')),
      );
      return;
    }
    if (!_isValidPhone(_recipient!.phone)) {
      ScaffoldMessenger.of(context).showUniqueSnackBar(
        const SnackBar(content: Text('올바른 전화번호를 확인해주세요')),
      );
      return;
    }

    final internationalPhone =
        convertToInternationalFormat(_recipient!.phone);
    debugPrint('수신자: ${_recipient!.name}, $internationalPhone');

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SuccessPaymentPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 44,
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          '선물 주문하기',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 보내는 사람
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  user?.name ?? '내 이름',
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(height: 24),

              // 상품 정보
              CommonPaymentWidget.getGiftInfo(),
              const SizedBox(height: 24),

              // 받는 분 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '받는 분',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _setGiftToMyself(!_giftToMyself),
                    child: Row(
                      children: [
                        Icon(
                          _giftToMyself
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 20,
                          color: _giftToMyself
                              ? ColorAssset.mainColor
                              : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        const Text('나에게 선물하기', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 연락처 가져오기 / 번호로 추가 버튼 (수신자 없을 때만)
              if (_recipient == null) ...[
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  onPressed: _pickFromContacts,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, size: 18),
                      SizedBox(width: 6),
                      Text('연락처 가져오기'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  onPressed: _showPhoneInputDialog,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.dialpad, size: 18),
                      SizedBox(width: 6),
                      Text('번호로 추가'),
                    ],
                  ),
                ),
              ],

              // 수신자 칩
              if (_recipient != null) ...[
                Text(
                  '총 1명',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          _recipient!.name,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          _recipient!.phone,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: _removeRecipient,
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // 전송수단
              const Text(
                '전송수단',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Radio<int>(
                    value: 0,
                    groupValue: 0,
                    onChanged: (_) {},
                    activeColor: ColorAssset.mainColor,
                  ),
                  const Text('문자'),
                ],
              ),
              const SizedBox(height: 24),

              // 결제수단
              const Text(
                '결제수단',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _PaymentMethodSection(),
              const SizedBox(height: 24),

              // 결제 버튼
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor: Colors.black,
                    backgroundColor: const Color(0xFFFFD400),
                  ),
                  onPressed: _onNext,
                  child: const Text(
                    '결제하기',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodSection extends StatefulWidget {
  @override
  State<_PaymentMethodSection> createState() => _PaymentMethodSectionState();
}

class _PaymentMethodSectionState extends State<_PaymentMethodSection> {
  int _selected = 0;
  final List<String> _methods = ['메가쿼크결제', '신용카드', '카카오페이'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_methods.length, (i) {
        return Row(
          children: [
            Radio<int>(
              value: i,
              groupValue: _selected,
              onChanged: (v) => setState(() => _selected = v!),
              activeColor: ColorAssset.mainColor,
            ),
            Text(_methods[i]),
          ],
        );
      }),
    );
  }
}
