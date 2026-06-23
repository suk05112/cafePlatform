import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// flutter_cache_manager is a transitive dependency of cached_network_image
import 'package:flutter_cache_manager/flutter_cache_manager.dart' as fcm;
import 'package:cafeplatform/Style/ColorAsset.dart';

class _AppCacheManager extends fcm.CacheManager with fcm.ImageCacheManager {
  static const _key = 'gifnut_img_1h';
  static final _AppCacheManager _instance = _AppCacheManager._();

  factory _AppCacheManager() => _instance;

  _AppCacheManager._()
      : super(fcm.Config(
          _key,
          stalePeriod: const Duration(hours: 1),
          maxNrOfCacheObjects: 200,
        ));
}

/// presigned URL처럼 쿼리스트링이 매번 바뀌는 경우:
/// [cacheKey]에 URL path 부분만 넘기면 캐시 히트를 유지합니다.
class CachedImage extends StatelessWidget {
  const CachedImage({
    super.key,
    required this.url,
    this.cacheKey,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackIcon = Icons.storefront_outlined,
  });

  final String url;
  final String? cacheKey;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;

  Widget _buildPlaceholder(double w, double h) => Container(
        width: w,
        height: h,
        color: Colors.grey.shade200,
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: ColorAssset.mainColor,
            ),
          ),
        ),
      );

  Widget _buildError(double w, double h) {
    final iconSize = (w < h ? w : h) * 0.45;
    return Container(
      width: w,
      height: h,
      color: Colors.grey.shade300,
      child: Icon(fallbackIcon, size: iconSize, color: Colors.white70),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cleanUrl = url.trim();
    final w = width ?? 80;
    final h = height ?? 80;

    if (cleanUrl.isEmpty ||
        (!cleanUrl.startsWith('http://') &&
            !cleanUrl.startsWith('https://'))) {
      return _buildError(w, h);
    }

    final key = cacheKey ?? (Uri.tryParse(cleanUrl)?.path ?? cleanUrl);

    Widget image = CachedNetworkImage(
      imageUrl: cleanUrl,
      cacheKey: key,
      cacheManager: _AppCacheManager(),
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => _buildPlaceholder(w, h),
      errorWidget: (_, __, ___) => _buildError(w, h),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}
