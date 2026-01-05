import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/gifticon_page.dart';
import 'package:cafeplatform/main.dart';
import 'package:cafeplatform/model/gifticon.dart';
import 'package:cafeplatform/model/user.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:cafeplatform/widget/network_aware_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GiftBox extends StatefulWidget {
  const GiftBox({super.key});

  @override
  _GiftBoxState createState() => _GiftBoxState();
}

class _GiftBoxState extends State<GiftBox> {
  List<Gifticon> usedGifticons = [];
  List<Gifticon> unusedGifticons = [];
  bool showUsed = false; // 현재 보여줄 리스트 선택 (true: 사용된 기프티콘, false: 미사용)

  @override
  void initState() {
    super.initState();
    print("_GiftBoxState initState");
    makeFakeData(); // 테스트용
    // fetchGifticons(); // API 호출 - 테스트 시 주석 처리
  }

  void makeFakeData() {
    print("🔹 makeFakeData 호출됨");
    setState(() {
      usedGifticons = [
        Gifticon(
            gifticon_id: 1,
            name: "사용된 기프티콘",
            status: "USED",
            store_name: "테스트 카페",
            sender: "sender",
            description: "description",
            validity: DateTime(2024, 1, 1)) // 과거 날짜로 설정
      ];
      unusedGifticons = [
        Gifticon(
            gifticon_id: 2,
            name: "사용안된 기프티콘",
            status: "UNUSED",
            store_name: "테스트 카페",
            sender: "sender",
            description: "description",
            validity: DateTime(2026, 12, 31)) // 미래 날짜로 설정
      ];
      print(
          "🔹 makeFakeData 완료 - usedGifticons: ${usedGifticons.length}, unusedGifticons: ${unusedGifticons.length}");
    });
  }

  Future<void> fetchGifticons() async {
    print("🔹 fetchGifticons 실행됨"); // ✅ 함수 호출 확인

    User? user =
        await Provider.of<UserProvider>(context, listen: false).fetchUser();

    if (user == null) {
      print("🚨 유저가 null임");
      return;
    }
    try {
      var response = await Api().client.getGifticonList(user.user_id);
      var gifticonList = response.gifticonList;

      setState(() {
        usedGifticons = gifticonList
            .where((gifticon) =>
                gifticon.status == 'USED' ||
                gifticon.status == 'EXPIRED' ||
                gifticon.status == 'CANCELED' ||
                (gifticon.validity != null &&
                    gifticon.validity!.isBefore(DateTime.now())))
            .toList();
        unusedGifticons = gifticonList
            .where((gifticon) =>
                gifticon.status == 'UNUSED' &&
                (gifticon.validity == null ||
                    (gifticon.validity!.isAfter(DateTime.now()) ||
                        gifticon.validity!.isAtSameMomentAs(DateTime.now()))))
            .toList();

        for (var gifticon in unusedGifticons) {
          print("unusedGifticons: ${gifticon.gifticon_id}");
          print("unusedGifticons: ${gifticon.toJson()}");
        }
      });
    } catch (error) {
      print("Error fetching gifticons: $error");
    }
  }

  void _navigateToHome() {
    Get.offAll(() => const TabPage(initialIndex: 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 44,
        title: const Text(
          "선물함",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.black),
            onPressed: _navigateToHome,
            tooltip: '홈으로 가기',
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: NetworkAwareWidget(
        onRetry: fetchGifticons,
        child: Column(
          children: <Widget>[
            // 탭 선택 버튼
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showUsed = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: !showUsed ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: !showUsed
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                    spreadRadius: 0,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            "미사용 (${unusedGifticons.length})",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  !showUsed ? FontWeight.w700 : FontWeight.w500,
                              color:
                                  !showUsed ? Colors.black87 : Colors.grey[500],
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showUsed = true;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: showUsed ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: showUsed
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                    spreadRadius: 0,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            "사용완료 (${usedGifticons.length})",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  showUsed ? FontWeight.w700 : FontWeight.w500,
                              color:
                                  showUsed ? Colors.black87 : Colors.grey[500],
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GifticonGridview(
                gifticonList: showUsed ? usedGifticons : unusedGifticons,
                showUsed: showUsed,
              ),
            ),
          ],
        ),
      ),
    );
  }
  // }
}

// ✅ GifticonGridview: API에서 받아온 데이터를 받아서 보여주는 위젯
class GifticonGridview extends StatelessWidget {
  final List<Gifticon> gifticonList;
  final bool showUsed;

  const GifticonGridview({
    super.key,
    required this.gifticonList,
    this.showUsed = false,
  });

  @override
  Widget build(BuildContext context) {
    if (gifticonList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              showUsed ? "사용 완료된 선물이 없습니다." : "사용 가능한 선물이 없습니다.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: gifticonList.length,
      itemBuilder: (context, index) {
        Gifticon gifticon = gifticonList[index];
        bool isUsedGift = isUsed(gifticon);
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GifticonPage(
                  gifticon_id: gifticon.gifticon_id,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 이미지 영역
                      Expanded(
                        flex: 3,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildMenuImage(gifticon.menu_url),
                            // 이미지 하단 그라데이션
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // 사용완료된 선물에 투명한 회색 오버레이
                            if (isUsedGift)
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.5),
                                      Colors.black.withOpacity(0.6),
                                    ],
                                  ),
                                ),
                              ),
                            if (isUsedGift)
                              Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 14,
                                        color: Colors.grey[700],
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "사용완료",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.grey[800],
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // 텍스트 영역
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(14, 14, 14, 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                gifticon.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isUsedGift
                                      ? Colors.grey[400]
                                      : Colors.black87,
                                  letterSpacing: -0.3,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.store,
                                    size: 12,
                                    color: isUsedGift
                                        ? Colors.grey[300]
                                        : Colors.grey[500],
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      gifticon.store_name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isUsedGift
                                            ? Colors.grey[300]
                                            : Colors.grey[600],
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ✅ 기프티콘이 사용되었는지 판별
  bool isUsed(Gifticon gifticon) {
    return gifticon.validity!.isBefore(DateTime.now());
  }

  // ✅ 메뉴 이미지 빌드 (URL 유효성 검사 포함)
  Widget _buildMenuImage(String? menuUrl) {
    final cleanedUrl = menuUrl?.trim() ?? '';

    // URL이 비어있거나 유효하지 않은 경우
    if (cleanedUrl.isEmpty ||
        (!cleanedUrl.startsWith('http://') &&
            !cleanedUrl.startsWith('https://'))) {
      // 이미지가 없을 때 예쁜 플레이스홀더 표시
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[100]!,
              Colors.grey[200]!,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/gifnut_logo.svg',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      );
    }

    // 유효한 URL이 있을 때 네트워크 이미지 표시
    return Image.network(
      cleanedUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[100]!,
                Colors.grey[200]!,
              ],
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // 네트워크 이미지 로드 실패 시 플레이스홀더 표시
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[100]!,
                Colors.grey[200]!,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/gifnut_logo.svg',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
