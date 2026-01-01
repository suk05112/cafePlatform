import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/main.dart';
import 'package:cafeplatform/model/gifticon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 돌아왔을 때
      _checkUnsentGift();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // 앱이 백그라운드로 갔을 때
      if (_isSharing) {
        _saveUnsentGift();
      }
    }
  }

  Future<void> _checkUnsentGift() async {
    if (_hasShownUnsentGiftDialog) return;

    final prefs = await SharedPreferences.getInstance();
    final unsentGifticonId = prefs.getString('unsent_gifticon_id');

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.card_giftcard, color: ColorAssset.mainColor),
            SizedBox(width: 8),
            Text(
              '안보낸 선물이 있어요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
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

    try {
      final gifticon = widget.gifticon!;
      final FeedTemplate defaultFeed = FeedTemplate(
        content: Content(
          title: '${gifticon.sender}님으로부터 선물이 도착했어요!',
          description: '${gifticon.sender}님이 선물을 보냈어요. 앱에서 바로 확인해보세요!',
          link: Link(
            webUrl: Uri.parse('https://developers.kakao.com'),
            mobileWebUrl: Uri.parse('https://developers.kakao.com'),
          ),
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
              androidExecutionParams: {
                'gifticon_id': '${gifticon.gifticon_id}'
              },
              iosExecutionParams: {'gifticon_id': '${gifticon.gifticon_id}'},
            ),
          ),
        ],
      );

      bool isKakaoTalkSharingAvailable =
          await ShareClient.instance.isKakaoTalkSharingAvailable();

      if (isKakaoTalkSharingAvailable) {
        Uri uri =
            await ShareClient.instance.shareDefault(template: defaultFeed);
        await ShareClient.instance.launchKakaoTalk(uri);
        print('카카오톡 공유 완료');
        // 공유 성공 시 저장된 정보 제거
        await _clearUnsentGift();
      } else {
        Uri shareUrl = await WebSharerClient.instance
            .makeDefaultUrl(template: defaultFeed);
        // 웹 공유는 카카오톡 앱이 없을 때만 사용
        print('카카오톡 미설치 - 웹 공유 URL: $shareUrl');
      }
    } catch (error) {
      print('카카오톡 공유 실패 $error');
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
