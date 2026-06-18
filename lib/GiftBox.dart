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
  String? _currentUserName;
  bool _isLoading = true;
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
    setState(() {
      _currentUserName = user.name;
    });
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
                (g.validity == null || !g.validity!.isBefore(DateTime.now())))
            .toList();
        _isLoading = false;
      });
    } catch (error) {
      print("Error fetching gifticons: $error");
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
              if (_hasImage) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    gifticon.menu_url!.trim(),
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        width: 72,
                        height: 72,
                        color: Colors.grey[100],
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('GiftBox image error: $error');
                      return Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
              ],
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
