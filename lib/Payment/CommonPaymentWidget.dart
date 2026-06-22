import 'package:flutter/material.dart';
import 'package:cafeplatform/model/menu.dart';
import 'package:cafeplatform/provider/menu_provider.dart';
import 'package:cafeplatform/widget/store_map_page.dart';
import 'package:cafeplatform/store_page.dart';
import 'package:provider/provider.dart';

class CommonPaymentWidget {
  /// 선물하기 등: 부모 가로에 맞춘 1:1 히어로 (스크롤/SafeArea 너비와 일치). URL 없으면 [SizedBox.shrink].
  static Widget buildGiftProductHeroImage(BuildContext context, Menu menu) {
    final raw = menu.menu_image_url?.trim();
    if (raw == null || raw.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        var side = constraints.maxWidth;
        if (!side.isFinite || side <= 0) {
          side = MediaQuery.sizeOf(context).width;
        }
        if (!side.isFinite || side <= 0) {
          return const SizedBox.shrink();
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: _giftMenuCoverImage(
                raw,
                borderRadius: 0,
                useDetailedPlaceholders: true,
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  static Widget _giftMenuCoverImage(
    String url, {
    required double borderRadius,
    bool useDetailedPlaceholders = false,
  }) {
    Widget net = Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        if (!useDetailedPlaceholders) return const SizedBox.shrink();
        return Container(
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        if (!useDetailedPlaceholders) return const SizedBox.shrink();
        return ColoredBox(
          color: Colors.grey.shade200,
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 40,
            color: Colors.grey.shade500,
          ),
        );
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
    );
    if (borderRadius <= 0) return net;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: net,
    );
  }

  /// 메뉴 이미지·이름·가격·설명·교환처(주소·지도).
  /// [asCard]: false면 그림자·라운드 카드 없이 본문만(선물하기 결제 화면 등).
  /// [skipImage]: true면 이미지 블록 생략(히어로를 밖에서 그릴 때).
  static Widget buildGiftProductCard(
    BuildContext context,
    Menu menu, {
    String? exchangeAddress,
    double? exchangeLat,
    double? exchangeLng,
    String? exchangePlaceName,
    int? contextStoreId,
    bool asCard = true,
    bool skipImage = false,
  }) {
    final hasImage =
        menu.menu_image_url != null && menu.menu_image_url!.trim().isNotEmpty;
    final desc = menu.description?.trim();
    final hasDesc = desc != null && desc.isNotEmpty;
    final addr = exchangeAddress?.trim();
    final hasAddr = addr != null && addr.isNotEmpty;
    final mapName = (exchangePlaceName != null && exchangePlaceName.isNotEmpty)
        ? exchangePlaceName
        : (menu.name ?? '매장');
    final showMap = _validMapCoords(exchangeLat, exchangeLng);

    final imageRadius = asCard ? 12.0 : 0.0;
    final column = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasImage && !skipImage) ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final side = constraints.maxWidth;
                if (!side.isFinite || side <= 0) {
                  return const SizedBox.shrink();
                }
                return SizedBox(
                  width: side,
                  height: side,
                  child: _giftMenuCoverImage(
                    menu.menu_image_url!.trim(),
                    borderRadius: imageRadius,
                    useDetailedPlaceholders: false,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
          if (exchangePlaceName != null && exchangePlaceName.isNotEmpty) ...[
            GestureDetector(
              onTap: () {
                final storeId = contextStoreId ?? (menu.store_id > 0 ? menu.store_id : null);
                if (storeId == null) return;
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => StorePage(storeId: storeId, storeName: exchangePlaceName),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    exchangePlaceName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF757575),
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 16, color: Color(0xFF757575)),
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            menu.name ?? "",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${menu.price}원",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (hasDesc) ...[
            const SizedBox(height: 8),
            Text(
              desc,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          const Text(
            '교환처',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasAddr ? addr : '등록된 주소가 없습니다.',
            style: TextStyle(
              fontSize: 13,
              color: hasAddr ? Colors.black87 : Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          if (showMap) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => StoreMapPage(
                        latitude: exchangeLat!,
                        longitude: exchangeLng!,
                        storeName: mapName,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.map_outlined, size: 20),
                label: const Text('지도로 보여주기'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ],
      );

    if (!asCard) {
      return column;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: column,
    );
  }

  static bool _validMapCoords(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (lat.abs() < 1e-5 && lng.abs() < 1e-5) return false;
    return lat >= 33.0 &&
        lat <= 38.8 &&
        lng >= 124.0 &&
        lng <= 132.5;
  }

  static Widget getGiftInfo() {
    return Consumer<MenuProvider>(builder: (context, menuProvider, child) {
      final menu = menuProvider.getSelectedMenu();
      return buildGiftProductCard(context, menu);
    });
  }
}

class InputInfoWidget extends StatefulWidget {
  InputInfoWidget(
      {super.key,
      required this.title,
      required this.hintText,
      required this.validator,
      required this.onChange});

  final String title;
  String hintText;
  Function(String?) validator;
  Function(String?) onChange;

  @override
  State<InputInfoWidget> createState() => _InputInfoWidgetState();
}

class _InputInfoWidgetState extends State<InputInfoWidget> {
  TextEditingController inputController = TextEditingController();

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10.0),
          Text(widget.title),
          TextFormField(
            controller: inputController,
            keyboardType: TextInputType.text,
            decoration: inputDecoration.copyWith(hintText: widget.hintText),
            validator: (value) {
              return widget.validator(value);
            },
            onChanged: (value) => widget.onChange(value),
          ),
        ]);
  }

  final inputDecoration = InputDecoration(
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2,
          )));
}

void showModalDialog(BuildContext context, String message) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Text("dialog");
      });
}
