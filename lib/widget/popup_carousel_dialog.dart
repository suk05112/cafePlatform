import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cafeplatform/api/popup_response.dart';
import 'package:url_launcher/url_launcher.dart';

class PopupCarouselDialog extends StatefulWidget {
  final List<PopupItem> popups;
  final VoidCallback onHideToday;
  final VoidCallback onClose;

  const PopupCarouselDialog({
    super.key,
    required this.popups,
    required this.onHideToday,
    required this.onClose,
  });

  @override
  State<PopupCarouselDialog> createState() => _PopupCarouselDialogState();
}

class _PopupCarouselDialogState extends State<PopupCarouselDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleTap(PopupItem popup) async {
    final url = popup.linkUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth * 0.85;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                width: dialogWidth,
                height: dialogWidth,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.popups.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final popup = widget.popups[index];
                    return GestureDetector(
                      onTap: () => _handleTap(popup),
                      child: CachedNetworkImage(
                        imageUrl: popup.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const ColoredBox(
                          color: Color(0xFFF5F5F5),
                        ),
                        errorWidget: (context, url, error) => const ColoredBox(
                          color: Color(0xFFF5F5F5),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (widget.popups.length > 1) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.popups.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? Colors.black
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onHideToday,
                      child: Text(
                        '오늘 하루 안보기',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 16,
                    color: Colors.grey.shade300,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onClose,
                      child: const Text(
                        '닫기',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
