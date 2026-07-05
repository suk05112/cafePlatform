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

/// presigned URL은 쿼리스트링이 매번 바뀌므로 path만 캐시 키로 사용해
/// 캐시 히트를 유지한다. [CachedImage]와 프리캐시가 동일 키를 쓰도록 공유.
String _cacheKeyFor(String cleanUrl) =>
    Uri.tryParse(cleanUrl)?.path ?? cleanUrl;

bool _isHttpUrl(String url) =>
    url.startsWith('http://') || url.startsWith('https://');

/// 주어진 이미지 URL들을 [CachedImage]와 동일한 캐시/캐시키로 미리 다운로드한다.
/// 홈 진입 전 스플래시나 다음 페이지 프리로드 시 호출해 프로그레스바 노출을 없앤다.
/// 개별 실패는 무시하며, 전체는 병렬로 처리한다.
Future<void> prefetchCachedImages(
    BuildContext context, Iterable<String> urls) async {
  final futures = <Future<void>>[];
  final seen = <String>{};
  for (final raw in urls) {
    final url = raw.trim();
    if (url.isEmpty || !_isHttpUrl(url)) continue;
    final key = _cacheKeyFor(url);
    if (!seen.add(key)) continue; // 같은 이미지 중복 프리캐시 방지
    if (!context.mounted) break;
    final provider = CachedNetworkImageProvider(
      url,
      cacheKey: key,
      cacheManager: _AppCacheManager(),
    );
    futures.add(precacheImage(provider, context).catchError((_) {}));
  }
  await Future.wait(futures);
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

    final key = cacheKey ?? _cacheKeyFor(cleanUrl);

    Widget image = CachedNetworkImage(
      imageUrl: cleanUrl,
      cacheKey: key,
      cacheManager: _AppCacheManager(),
      width: width,
      height: height,
      fit: fit,
      // 캐시 히트 시 즉각 표시 (흐릿→선명 전환 없음).
      // 미스(최초 다운로드) 시에는 placeholder → fade-in이 자연스럽게 동작한다.
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: (_, __) => _buildPlaceholder(w, h),
      errorWidget: (_, __, ___) => _buildError(w, h),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}
