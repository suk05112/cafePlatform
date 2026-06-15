import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/gifticon_page.dart';
import 'package:cafeplatform/main.dart';
import 'package:cafeplatform/model/gifticon.dart';
import 'package:cafeplatform/model/user.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:cafeplatform/widget/network_aware_widget.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class GiftBox extends StatefulWidget {
  const GiftBox({super.key});

  @override
  _GiftBoxState createState() => _GiftBoxState();
}

class _GiftBoxState extends State<GiftBox> with SingleTickerProviderStateMixin {
  List<Gifticon> usedGifticons = [];
  List<Gifticon> unusedGifticons = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchGifticons();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchGifticons() async {
    User? user =
        await Provider.of<UserProvider>(context, listen: false).fetchUser();
    if (user == null) return;
    try {
      await Api().setBaseClient(Api.BASE_URL);
      var response = await Api().client.getGifticonList(user.user_id);
      var gifticonList = response.gifticonList;

      setState(() {
        usedGifticons = gifticonList
            .where((g) =>
                g.status == 'USED' ||
                g.status == 'EXPIRED' ||
                g.status == 'CANCELED' ||
                (g.validity != null && g.validity!.isBefore(DateTime.now())))
            .toList();
        unusedGifticons = gifticonList
            .where((g) =>
                g.status == 'UNUSED' &&
                (g.validity == null ||
                    !g.validity!.isBefore(DateTime.now())))
            .toList();
      });
    } catch (error) {
      print("Error fetching gifticons: $error");
    }
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
            icon: const Icon(Icons.home_outlined, color: Colors.black),
            onPressed: () => Get.offAll(() => const TabPage(initialIndex: 0)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              Container(height: 1, color: Colors.grey[100]),
              TabBar(
                controller: _tabController,
                indicatorColor: ColorAssset.mainColor,
                indicatorWeight: 2.5,
                labelColor: ColorAssset.mainColor,
                unselectedLabelColor: Colors.grey[400],
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.3,
                ),
                tabs: [
                  Tab(text: "미사용 (${unusedGifticons.length})"),
                  Tab(text: "사용완료 (${usedGifticons.length})"),
                ],
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: NetworkAwareWidget(
        onRetry: fetchGifticons,
        child: TabBarView(
          controller: _tabController,
          children: [
            _GifticonListView(gifticonList: unusedGifticons, isUsed: false),
            _GifticonListView(gifticonList: usedGifticons, isUsed: true),
          ],
        ),
      ),
    );
  }
}

class _GifticonListView extends StatelessWidget {
  final List<Gifticon> gifticonList;
  final bool isUsed;

  const _GifticonListView({
    required this.gifticonList,
    required this.isUsed,
  });

  @override
  Widget build(BuildContext context) {
    if (gifticonList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUsed ? Icons.check_circle_outline : Icons.card_giftcard_outlined,
              size: 56,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 14),
            Text(
              isUsed ? "사용 완료된 선물이 없습니다." : "사용 가능한 선물이 없습니다.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: gifticonList.length,
      itemBuilder: (context, index) {
        return _GifticonCard(gifticon: gifticonList[index], isUsed: isUsed);
      },
    );
  }
}

class _GifticonCard extends StatelessWidget {
  final Gifticon gifticon;
  final bool isUsed;

  const _GifticonCard({required this.gifticon, required this.isUsed});

  String _formatValidity(DateTime? validity) {
    if (validity == null) return '';
    return '${DateFormat('yyyy.MM.dd').format(validity)} 까지';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GifticonPage(gifticon_id: gifticon.gifticon_id),
          ),
        );
      },
      child: Opacity(
        opacity: isUsed ? 0.5 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 이미지 영역
                Expanded(
                  flex: 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildThumbnail(),
                      if (isUsed)
                        Container(
                          color: Colors.black.withValues(alpha: 0.35),
                        ),
                      if (isUsed)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "사용완료",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[600],
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // 텍스트 영역
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          gifticon.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isUsed ? Colors.grey[400] : Colors.black87,
                            letterSpacing: -0.3,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gifticon.store_name,
                              style: TextStyle(
                                fontSize: 11,
                                color: isUsed ? Colors.grey[300] : Colors.grey[500],
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (gifticon.validity != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                _formatValidity(gifticon.validity),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isUsed ? Colors.grey[300] : ColorAssset.mainColor.withValues(alpha: 0.7),
                                  letterSpacing: -0.2,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    final cleanedUrl = gifticon.menu_url?.trim() ?? '';
    final hasValidUrl = cleanedUrl.startsWith('http://') || cleanedUrl.startsWith('https://');

    if (!hasValidUrl) {
      return _noImagePlaceholder();
    }

    return Image.network(
      cleanedUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _shimmerPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) => _noImagePlaceholder(),
    );
  }

  Widget _noImagePlaceholder() {
    return Container(
      color: const Color(0xFFF2F3F5),
      child: Center(
        child: Icon(
          Icons.local_cafe_outlined,
          size: 32,
          color: Colors.grey[350],
        ),
      ),
    );
  }

  Widget _shimmerPlaceholder() {
    return Container(color: const Color(0xFFF2F3F5));
  }
}
