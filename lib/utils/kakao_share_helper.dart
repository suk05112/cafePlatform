import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:cafeplatform/model/gifticon.dart';
import 'package:url_launcher/url_launcher.dart';

/// 카카오톡 링크 공유를 위한 공통 유틸리티 클래스
class KakaoShareHelper {
  /// 기프티콘을 카카오톡으로 공유하는 함수
  ///
  /// [gifticon] 공유할 기프티콘 정보
  /// [onSuccess] 공유 성공 시 호출할 콜백 (선택사항)
  /// [onError] 공유 실패 시 호출할 콜백 (선택사항)
  static Future<void> shareGifticon(
    Gifticon gifticon, {
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      // FeedTemplate 생성
      final FeedTemplate defaultFeed = _createGifticonFeedTemplate(gifticon);

      // 카카오톡 실행 가능 여부 확인
      bool isKakaoTalkSharingAvailable =
          await ShareClient.instance.isKakaoTalkSharingAvailable();

      if (isKakaoTalkSharingAvailable) {
        // 카카오톡 앱이 설치된 경우
        try {
          Uri uri =
              await ShareClient.instance.shareDefault(template: defaultFeed);
          await ShareClient.instance.launchKakaoTalk(uri);
          print('카카오톡 공유 완료');
          onSuccess?.call();
        } catch (error) {
          print('카카오톡 공유 실패 $error');
          onError?.call('카카오톡 공유에 실패했습니다: $error');
        }
      } else {
        // 카카오톡 앱이 설치되지 않은 경우 웹 공유
        try {
          Uri shareUrl = await WebSharerClient.instance
              .makeDefaultUrl(template: defaultFeed);
          await launchBrowserTab(shareUrl, popupOpen: true);
          print('카카오톡 미설치 - 웹 공유 URL: $shareUrl');
          onSuccess?.call();
        } catch (error) {
          print('카카오톡 웹 공유 실패 $error');
          onError?.call('카카오톡 공유에 실패했습니다: $error');
        }
      }
    } catch (error) {
      print('카카오톡 공유 오류: $error');
      onError?.call('카카오톡 공유 중 오류가 발생했습니다: $error');
    }
  }

  /// 기프티콘 정보를 기반으로 FeedTemplate 생성
  static FeedTemplate _createGifticonFeedTemplate(Gifticon gifticon) {
    return FeedTemplate(
      content: Content(
        title: '${gifticon.sender}님으로부터 선물이 도착했어요!',
        description: '${gifticon.sender}님이 선물을 보냈어요. 앱에서 바로 확인해보세요!',
        link: Link(
          // 메인 콘텐츠 링크 (선택적으로 앱 다운로드 페이지나 메인 페이지로 설정)
          webUrl: Uri.parse('https://www.502company.com'),
          mobileWebUrl: Uri.parse('https://www.502company.com'),
        ),
      ),
      itemContent: ItemContent(
        profileText: 'Gifnut',
        // TODO: S3 버킷을 public으로 설정하거나, CloudFront나 다른 public 호스팅 사용 필요
        // 현재는 임시로 null 설정 (카카오톡 기본 프로필 이미지 사용)
        profileImageUrl: Uri.parse(
            'https://cafeplatform-dev.s3.amazonaws.com/gifnut-common-resouces/gifnut-logo.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQD4W7YEDZS7TU7NB%2F20260104%2Fap-northeast-2%2Fs3%2Faws4_request&X-Amz-Date=20260104T223347Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=2039fc9fca3ecd09a89ba95eddbb93311515acbf340558d0a247876db7d5f5dc'),
        // 메뉴 이미지가 있으면 사용, 없으면 null로 설정하여 표시하지 않음
        titleImageUrl:
            (gifticon.menu_url != null && gifticon.menu_url!.isNotEmpty)
                ? Uri.parse(gifticon.menu_url!)
                : null,
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
            // 웹 URL (App Links/Universal Links를 통해 앱으로 연결)
            // Android: AndroidManifest.xml에 https://www.502company.com/gift가 App Links로 설정되어 있음
            // iOS: Runner.entitlements에 applinks:www.502company.com이 Associated Domains로 설정되어 있음
            webUrl: Uri.parse(
                'https://www.502company.com/gift?gifticon_id=${gifticon.gifticon_id}'),
            // iOS에서는 Universal Links가 카카오톡에서 제대로 작동하지 않을 수 있으므로
            // 커스텀 스킴도 함께 사용 (웹 서버에서 JavaScript로 앱 열기 시도)
            mobileWebUrl: Uri.parse(
                'https://www.502company.com/gift?gifticon_id=${gifticon.gifticon_id}'),
            // 앱 실행 시 전달될 파라미터
            // Android: androidExecutionParams가 앱으로 전달됨
            // iOS: iosExecutionParams가 앱으로 전달되지만, Universal Links를 통해 들어올 때는 query parameter로 전달됨
            androidExecutionParams: {'gifticon_id': '${gifticon.gifticon_id}'},
            iosExecutionParams: {'gifticon_id': '${gifticon.gifticon_id}'},
          ),
        ),
      ],
    );
  }

  /// 브라우저 탭으로 URL 열기
  static Future<void> launchBrowserTab(Uri url,
      {bool popupOpen = false}) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: popupOpen
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault,
      );
    } else {
      throw Exception('Could not launch $url');
    }
  }
}
