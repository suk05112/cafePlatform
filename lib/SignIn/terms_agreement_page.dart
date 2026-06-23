import 'package:flutter/material.dart';
import 'package:cafeplatform/SignIn/phone_auth_page.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/setting/terms_page.dart';

enum TermsType {
  service('SERVICE'),
  privacy('PRIVACY'),
  marketing('MARKETING'),
  location('LOCATION');

  const TermsType(this.termType);
  final String termType;
}

class TermsAgreementPage extends StatefulWidget {
  const TermsAgreementPage({
    super.key,
    this.isSocialLogin = false,
    this.provider,
  });

  final bool isSocialLogin;
  final String? provider; // SNS provider 또는 "email"

  @override
  State<TermsAgreementPage> createState() => _TermsAgreementPageState();
}

class _TermsAgreementPageState extends State<TermsAgreementPage> {
  bool agreeAll = false;
  bool agreeService = false;
  bool agreePrivacy = false;
  bool agreeMarketing = false;
  bool agreeAge = false;
  bool agreeLocation = false;

  bool get _canProceed => agreeService && agreePrivacy && agreeAge;

  void _toggleAll(bool? value) {
    final checked = value ?? false;
    setState(() {
      agreeAll = checked;
      agreeService = checked;
      agreePrivacy = checked;
      agreeMarketing = checked;
      agreeAge = checked;
      agreeLocation = checked;
    });
  }

  void _toggleItem({
    required bool value,
    required ValueSetter<bool> update,
  }) {
    setState(() {
      update(!value);
      agreeAll = agreeService && agreePrivacy && agreeMarketing && agreeAge && agreeLocation;
    });
  }

  Future<void> _openTermsSite(TermsType type) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TermsWebViewPage(
          title: _termTitle(type),
          termType: type.termType,
        ),
      ),
    );
  }

  String _termTitle(TermsType type) {
    switch (type) {
      case TermsType.service:
        return '이용약관';
      case TermsType.privacy:
        return '개인정보 수집 및 이용동의';
      case TermsType.marketing:
        return 'E-mail 및 SMS 광고성 정보 수신동의';
      case TermsType.location:
        return '위치서비스 이용약관';
    }
  }

  Future<void> _handleNext() async {
    if (!_canProceed) return;
    final phoneAuthResult = await Navigator.push<PhoneAuthResult?>(
      context,
      MaterialPageRoute(
          builder: (_) => PhoneAuthPage(
                isSocialLogin: widget.isSocialLogin,
                provider: widget.provider,
              )),
    );
    if (phoneAuthResult != null && mounted) {
      Navigator.pop(context, phoneAuthResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const CommonAppBar(title: "약관동의"),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(height: 200),
                // Expanded(
                //   child: Container(), // 빈 공간
                // ),
                _AgreementTile(
                  label: '약관 전체동의',
                  requiredLabel: '',
                  value: agreeAll,
                  onChanged: _toggleAll,
                  onLinkTap: null,
                  isAll: true,
                ),
                const Divider(height: 16),
                _AgreementTile(
                  label: '이용약관 동의',
                  requiredLabel: '(필수)',
                  value: agreeService,
                  onChanged: (_) => _toggleItem(
                    value: agreeService,
                    update: (checked) => agreeService = checked,
                  ),
                  onLinkTap: () => _openTermsSite(TermsType.service),
                ),
                _AgreementTile(
                  label: '만 14세 이상입니다',
                  requiredLabel: '(필수)',
                  value: agreeAge,
                  onChanged: (_) => _toggleItem(
                    value: agreeAge,
                    update: (checked) => agreeAge = checked,
                  ),
                  onLinkTap: null,
                ),
                _AgreementTile(
                  label: '개인정보 수집 및 이용동의',
                  requiredLabel: '(필수)',
                  value: agreePrivacy,
                  onChanged: (_) => _toggleItem(
                    value: agreePrivacy,
                    update: (checked) => agreePrivacy = checked,
                  ),
                  onLinkTap: () => _openTermsSite(TermsType.privacy),
                ),
                _AgreementTile(
                  label: 'E-mail 및 SMS 광고성 정보 수신동의',
                  requiredLabel: '(선택)',
                  value: agreeMarketing,
                  onChanged: (_) => _toggleItem(
                    value: agreeMarketing,
                    update: (checked) => agreeMarketing = checked,
                  ),
                  onLinkTap: () => _openTermsSite(TermsType.marketing),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Text(
                    '다양한 프로모션 소식 및 신규 매장 정보를 보내 드립니다.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _AgreementTile(
                  label: '위치서비스 이용약관',
                  requiredLabel: '(선택)',
                  value: agreeLocation,
                  onChanged: (_) => _toggleItem(
                    value: agreeLocation,
                    update: (checked) => agreeLocation = checked,
                  ),
                  onLinkTap: () => _openTermsSite(TermsType.location),
                ),
                const SizedBox(height: 24),
                Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _canProceed ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorAssset.mainColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '다음',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AgreementTile extends StatelessWidget {
  const _AgreementTile({
    required this.label,
    required this.requiredLabel,
    required this.value,
    required this.onChanged,
    this.onLinkTap,
    this.isAll = false,
  });

  final String label;
  final String requiredLabel;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final VoidCallback? onLinkTap;
  final bool isAll;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      splashColor: Colors.grey[100],
      highlightColor: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                shape: const CircleBorder(),
                activeColor: Colors.black,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: label,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: isAll ? 15 : 14,
                    fontWeight: isAll ? FontWeight.w600 : FontWeight.w400,
                    height: 1.3,
                  ),
                  children: [
                    if (requiredLabel.isNotEmpty)
                      TextSpan(
                        text: ' $requiredLabel',
                        style: TextStyle(
                          color: requiredLabel.contains('필수')
                              ? Colors.redAccent
                              : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (onLinkTap != null)
              GestureDetector(
                onTap: onLinkTap,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

