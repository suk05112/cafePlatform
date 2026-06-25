import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/main.dart';
import 'package:cafeplatform/model/gifticon.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cafeplatform/utils/kakao_share_helper.dart';

class CompletePayment extends StatefulWidget {
  final int? giftType; // 0: 나에게 선물하기, 1: 선물하기
  final Gifticon? gifticon;

  const CompletePayment({super.key, this.giftType, this.gifticon});

  @override
  State<CompletePayment> createState() => _CompletePaymentState();
}

class _CompletePaymentState extends State<CompletePayment>
    with WidgetsBindingObserver {
  bool _isSharing = false;
  bool _hasShownUnsentGiftDialog = false;
  bool _showGiftCompleteScreen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkUnsentGift();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 돌아왔을 때
      await _checkSharingComplete();
      // 공유가 완료되지 않은 경우에만 안보낸 선물 체크
      if (!_showGiftCompleteScreen) {
        _checkUnsentGift();
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // 앱이 백그라운드로 갔을 때
      // 공유가 진행 중이고 아직 완료 화면이 표시되지 않은 경우에만 저장
      // 하지만 sharing_in_progress가 false면 이미 완료된 것이므로 저장하지 않음
      if (_isSharing && !_showGiftCompleteScreen) {
        final prefs = await SharedPreferences.getInstance();
        final sharingInProgress = prefs.getBool('sharing_in_progress') ?? false;
        if (sharingInProgress) {
          _saveUnsentGift();
        }
      }
    }
  }

  Future<void> _checkSharingComplete() async {
    if (widget.giftType != 1 || widget.gifticon == null) return;

    final prefs = await SharedPreferences.getInstance();
    final sharingInProgress = prefs.getBool('sharing_in_progress') ?? false;

    // 공유 중이었다가 앱으로 돌아온 경우 완료 화면 표시
    if (sharingInProgress && _isSharing) {
      await prefs.remove('sharing_in_progress');
      // 공유 완료 시 안보낸 선물 정보도 제거
      await _clearUnsentGift();
      if (mounted) {
        setState(() {
          _isSharing = false;
          _showGiftCompleteScreen = true;
        });
      }
    }
  }

  Future<void> _checkUnsentGift() async {
    if (_hasShownUnsentGiftDialog) return;

    final prefs = await SharedPreferences.getInstance();
    final unsentGifticonId = prefs.getString('unsent_gifticon_id');
    final sharingInProgress = prefs.getBool('sharing_in_progress') ?? false;

    // 공유가 진행 중이면 안보낸 선물로 처리하지 않음
    if (sharingInProgress) {
      return;
    }

    if (unsentGifticonId != null && unsentGifticonId.isNotEmpty) {

      _hasShownUnsentGiftDialog = true;
      _showUnsentGiftDialog();
    }
  }

  Future<void> _saveUnsentGift() async {
    if (widget.gifticon == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'unsent_gifticon_id', widget.gifticon!.gifticon_id.toString());
    await prefs.setString('unsent_gifticon_name', widget.gifticon!.name);
  }

  Future<void> _clearUnsentGift() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('unsent_gifticon_id');
    await prefs.remove('unsent_gifticon_name');
  }

  void _showUnsentGiftDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        content: Text(
          '카카오톡 선물 보내기를 완료하지 못했습니다.\n다시 보내시겠어요?',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearUnsentGift();
              Navigator.of(context).pop();
            },
            child: Text(
              '나중에',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _shareToKakaoTalk();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorAssset.mainColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('다시 보내기'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareToKakaoTalk() async {
    if (widget.gifticon == null) return;

    setState(() {
      _isSharing = true;
    });

    // 공유 시작 플래그 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sharing_in_progress', true);

    try {
      await KakaoShareHelper.shareGifticon(
        widget.gifticon!,
        onSuccess: () async {
          // 공유 성공 시 저장된 정보 모두 제거
          await _clearUnsentGift();
          // sharing_in_progress는 유지하여 앱 복귀 시 완료 화면 표시
          // _checkSharingComplete에서 제거함
          // _isSharing은 앱 복귀 시 _checkSharingComplete에서 false로 설정됨
        },
        onError: (error) async {
          // 공유 실패 시 플래그 제거
          await prefs.remove('sharing_in_progress');
          if (mounted) {
            setState(() {
              _isSharing = false;
            });
          }
        },
      );
    } catch (error) {
      prefs.remove('sharing_in_progress');
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
    // onSuccess나 onError에서 처리하지 않고 앱 복귀 시 처리
  }

  @override
  Widget build(BuildContext context) {
    // 선물하기 완료 화면 표시
    if (_showGiftCompleteScreen) {
      return WillPopScope(
        onWillPop: () async => false, // 뒤로가기 버튼 비활성화
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
                  // 성공 아이콘
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: ColorAssset.mainColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Icon(
                        Icons.card_giftcard,
                        size: 80,
                        color: ColorAssset.mainColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 제목
                  const Text(
                    "선물이 전달되었어요!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 48),
                  // 홈으로 돌아가기 버튼
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
                      child: const Text(
                        '홈으로 돌아가기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => TabPage()),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 기존 결제 완료 화면
    return WillPopScope(
      onWillPop: () async => false, // 뒤로가기 버튼 비활성화
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
                // 성공 아이콘
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: ColorAssset.mainColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(
                      'assets/icon.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // 이미지가 없으면 기본 아이콘 표시
                        return Icon(
                          Icons.check_circle,
                          size: 80,
                          color: ColorAssset.mainColor,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // 제목
                const Text(
                  "결제가 완료되었어요!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                // 부제목
                Text(
                  widget.giftType == 0
                      ? "선물함에서 확인하실 수 있어요"
                      : "주문 내역에서 확인하실 수 있어요",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // 버튼들
                if (widget.giftType == 0) ...[
                  // 나에게 선물하기인 경우: 선물함으로 이동
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
                      child: const Text(
                        '선물함으로 이동',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        context.read<UserProvider>().invalidateGifticonCache();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => TabPage(initialIndex: 1)),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        '홈으로 돌아가기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () {
                        context.read<UserProvider>().invalidateGifticonCache();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => TabPage()),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                ] else ...[
                  // 선물하기인 경우: 카카오톡 공유 버튼과 홈으로 이동 버튼
                  if (widget.gifticon != null) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          foregroundColor: Colors.white,
                          backgroundColor: ColorAssset.mainColor,
                          elevation: 0,
                        ),
                        icon: Icon(Icons.share),
                        label: Text(
                          '카카오톡으로 선물 보내기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _isSharing ? null : _shareToKakaoTalk,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        '홈으로 돌아가기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () {
                        context.read<UserProvider>().invalidateGifticonCache();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => TabPage()),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                ],
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
