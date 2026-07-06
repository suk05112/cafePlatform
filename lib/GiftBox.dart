import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cafeplatform/utils/analytics_service.dart';
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
  String? _currentUserName;
  bool _isLoading = true;
  late TabController _tabController;
  bool _prevLoggedIn = false;
  bool _prevCacheValid = false;
  bool _initialFetchDone = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView('gift_box');
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context);
    final loggedIn = userProvider.isLoggedIn;
    final cacheValid = userProvider.isGifticonCacheValid;

    if (!_initialFetchDone) {
      // 최초 1회 로드
      _initialFetchDone = true;
      _prevLoggedIn = loggedIn;
      _prevCacheValid = cacheValid;
      fetchGifticons();
    } else if (loggedIn && !_prevLoggedIn) {
      // 로그아웃 → 로그인 전환
      setState(() => _isLoading = true);
      fetchGifticons();
    } else if (loggedIn && _prevCacheValid && !cacheValid) {
      // 캐시 무효화 → 강제 새로고침
      setState(() => _isLoading = true);
      fetchGifticons(forceRefresh: true);
    }

    _prevLoggedIn = loggedIn;
    _prevCacheValid = cacheValid;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _applyGifticonList(List<Gifticon> gifticonList) {
    final now = DateTime.now();
    final used = gifticonList.where((g) {
      final s = g.status?.toUpperCase();
      return s == 'USED' || s == 'EXPIRED' || s == 'CANCELED' ||
          (g.validity != null && g.validity!.isBefore(now));
    }).toList();
    final unused = gifticonList.where((g) {
      final s = g.status?.toUpperCase();
      final isExpiredByDate = g.validity != null && g.validity!.isBefore(now);
      return (s == 'UNUSED' || s == 'PENDING') && !isExpiredByDate;
    }).toList();
    setState(() {
      usedGifticons = used;
      unusedGifticons = unused;
      _isLoading = false;
    });
  }

  Future<void> fetchGifticons({bool forceRefresh = false}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    User? user = await userProvider.fetchUser();
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    if (mounted) setState(() => _currentUserName = user.name);

    // 캐시가 유효하고 강제 새로고침이 아니면 캐시 사용
    if (!forceRefresh && userProvider.isGifticonCacheValid) {
      if (mounted) _applyGifticonList(userProvider.cachedGifticons!);
      return;
    }

    try {
      await Api().setBaseClient(Api.BASE_URL);
      var response = await Api().client.getGifticonList(user.user_id);
      var gifticonList = response.gifticonList;
      userProvider.setGifticonCache(gifticonList);

      if (!mounted) return;
      _applyGifticonList(gifticonList);
    } catch (error, st) {
      debugPrint('[GiftBox] fetchGifticons error: $error\n$st');
      setState(() => _isLoading = false);
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              Container(height: 1, color: Colors.grey[200]),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.black87,
                indicatorWeight: 2,
                dividerColor: Colors.transparent,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                labelColor: Colors.black87,
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
      backgroundColor: Colors.white,
      body: NetworkAwareWidget(
        onRetry: fetchGifticons,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: ColorAssset.mainColor,
                  strokeWidth: 2.5,
                ),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  _GifticonListView(
                    gifticonList: unusedGifticons,
                    currentUserName: _currentUserName,
                  ),
                  _GifticonListView(
                    gifticonList: usedGifticons,
                    currentUserName: _currentUserName,
                  ),
                ],
              ),
      ),
    );
  }
}

class _GifticonListView extends StatelessWidget {
  final List<Gifticon> gifticonList;
  final String? currentUserName;

  const _GifticonListView({
    required this.gifticonList,
    required this.currentUserName,
  });

  @override
  Widget build(BuildContext context) {
    if (gifticonList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard_outlined, size: 52, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              "선물이 없습니다.",
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

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: gifticonList.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[100]),
      itemBuilder: (context, index) {
        return _GifticonRow(
          gifticon: gifticonList[index],
          currentUserName: currentUserName,
        );
      },
    );
  }
}

class _GifticonRow extends StatelessWidget {
  final Gifticon gifticon;
  final String? currentUserName;

  const _GifticonRow({required this.gifticon, required this.currentUserName});

  bool get _isUsed {
    return gifticon.status == 'USED' ||
        gifticon.status == 'EXPIRED' ||
        gifticon.status == 'CANCELED' ||
        (gifticon.validity != null && gifticon.validity!.isBefore(DateTime.now()));
  }

  bool get _showSender {
    if (gifticon.sender.isEmpty) return false;
    return gifticon.sender != currentUserName;
  }

  String _formatValidity(DateTime validity) {
    return '${DateFormat('yyyy.MM.dd').format(validity)} 까지';
  }

  bool get _hasImage {
    final url = gifticon.menu_url?.trim() ?? '';
    return url.startsWith('http://') || url.startsWith('https://');
  }

  Widget _imagePlaceholder() => Container(
        width: 72,
        height: 72,
        color: Colors.grey[100],
        child: Icon(Icons.local_cafe_outlined, color: Colors.grey[300], size: 28),
      );

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
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: _isUsed ? 0.45 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _hasImage
                    ? Image.network(
                        gifticon.menu_url!.trim(),
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return _imagePlaceholder();
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gifticon.store_name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      gifticon.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: -0.4,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_showSender) ...[
                      const SizedBox(height: 2),
                      Text(
                        'From. ${gifticon.sender}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                    if (gifticon.validity != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatValidity(gifticon.validity!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 18, color: Colors.grey[300]),
            ],
          ),
        ),
      ),
    );
  }
}
