import 'package:dio/dio.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/api/link_gifticon_request.dart';
import 'package:cafeplatform/gifticon_page.dart';
import 'package:cafeplatform/main.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:cafeplatform/utils/business_info_helper.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:provider/provider.dart';

class RegisterGifticonPage extends StatefulWidget {
  final int gifticon_id;

  const RegisterGifticonPage({
    super.key,
    required this.gifticon_id,
  });

  @override
  State<RegisterGifticonPage> createState() => _RegisterGifticonPageState();
}

class _RegisterGifticonPageState extends State<RegisterGifticonPage> {
  bool _isLoading = false;
  String? _errorMessage;
  // 유효하지 않은 링크(결제 미완료/삭제 등)인 경우 true → 다시 시도 숨기고 고객센터 안내
  bool _isInvalidLink = false;
  String? _customerServicePhone;

  @override
  void initState() {
    super.initState();
    _registerGifticon();
  }

  /// 유효하지 않은 링크일 때 고객센터 번호를 조회해 안내 문구에 노출
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

  void _navigateToHome() {
    Get.offAll(() => const TabPage(initialIndex: 0));
  }

  Future<void> _registerGifticon() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isInvalidLink = false;
    });

    try {
      // 사용자 정보 가져오기
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;

      if (user == null) {
        setState(() {
          _errorMessage = '로그인이 필요합니다.';
          _isLoading = false;
        });
        return;
      }

      if (user.phone_number.isEmpty) {
        setState(() {
          _errorMessage = '전화번호 정보가 없습니다.';
          _isLoading = false;
        });
        return;
      }

      // 전화번호에서 하이픈 제거 (API는 숫자만 받을 수 있음)
      final phoneNumber = user.phone_number;


      // API 호출
      await Api().setBaseClient(Api.BASE_URL);
      final request = LinkGifticonRequest(
        user_id: user.user_id,
        gifticon_id: widget.gifticon_id,
        receiver_phone: phoneNumber,
      );

      final response = await Api().client.linkGifticonToUser(request);

      // 등록 성공 시 캐시 무효화 후 기프티콘 페이지로 이동
      if (mounted) {
        Provider.of<UserProvider>(context, listen: false).invalidateGifticonCache();
        Get.off(() => GifticonPage(gifticon_id: widget.gifticon_id, fromKakao: true));
      }
    } on DioException catch (error) {
      String errorMessage = '기프티콘 등록 중 오류가 발생했습니다.';
      bool isInvalidLink = false;

      // 서버 에러 메시지 확인
      if (error.response != null) {
        final statusCode = error.response?.statusCode;
        final errorData = error.response?.data;

        if (statusCode == 400) {
          if (errorData != null && errorData is Map) {
            final detail = errorData['detail'] as String?;
            if (detail != null) {
              if (detail.contains('phone number does not match')) {
                errorMessage = '전화번호가 일치하지 않습니다.\n상품권에 등록된 전화번호와 다릅니다.';
              } else if (detail.contains('already linked')) {
                errorMessage = '이미 다른 사용자에게 등록된 선물입니다.';
              } else if (detail.contains('not ready')) {
                // 결제가 완료되지 않은(PENDING) 기프티콘 → 유효하지 않은 링크로 안내
                errorMessage = '유효하지 않은 선물 링크입니다.';
                isInvalidLink = true;
              } else {
                errorMessage = detail;
              }
            }
          }
        } else if (statusCode == 404) {
          // 존재하지 않는 기프티콘 → 유효하지 않은 링크로 안내
          errorMessage = '유효하지 않은 선물 링크입니다.';
          isInvalidLink = true;
        }
      }

      setState(() {
        _errorMessage = errorMessage;
        _isInvalidLink = isInvalidLink;
        _isLoading = false;
      });

      if (isInvalidLink) {
        _loadCustomerServicePhone();
      }
    } catch (error) {
      setState(() {
        _errorMessage = '기프티콘 등록 중 오류가 발생했습니다.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: "기프티콘 등록"),
      body: SafeArea(
        child: Center(
          child: _isLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: ColorAssset.mainColor),
                    SizedBox(height: 24),
                    Text(
                      '기프티콘을 등록하는 중입니다...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 32),
                    TextButton(
                      onPressed: () {
                        _navigateToHome();
                      },
                      child: Text(
                        '홈으로 가기',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                )
              : _errorMessage != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          // 유효하지 않은 링크: 문제가 반복될 경우 고객센터 안내 (텍스트만)
                          if (_isInvalidLink) ...[
                            SizedBox(height: 12),
                            Text(
                              _customerServicePhone != null
                                  ? '문제가 계속되면 고객센터로 문의해 주세요.\n$_customerServicePhone'
                                  : '문제가 계속되면 고객센터로 문의해 주세요.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 유효하지 않은 링크는 재시도해도 소용없으므로 숨김
                              if (!_isInvalidLink) ...[
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _errorMessage = null;
                                    });
                                    _registerGifticon();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text('다시 시도'),
                                ),
                                SizedBox(width: 12),
                              ],
                              OutlinedButton(
                                onPressed: () {
                                  _navigateToHome();
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  side: BorderSide(color: Colors.grey[400]!),
                                ),
                                child: Text(
                                  '홈으로 가기',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
        ),
      ),
    );
  }
}
