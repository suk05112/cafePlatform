import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:cafeplatform/model/gifticon.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

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
      // FeedTemplate 생성 (비동기로 presigned URL 가져오기)
      final FeedTemplate defaultFeed =
          await _createGifticonFeedTemplate(gifticon);

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
  static Future<FeedTemplate> _createGifticonFeedTemplate(
      Gifticon gifticon) async {
    // API에서 로고 presigned URL 가져오기
    Uri? profileImageUri;
    try {
      await Api().setBaseClient(Api.BASE_URL);
      final response = await Api().client.getGifnutImageUrl(
            expiresIn: 3600, // 1시간 (기본값)
          );
      if (response.url.isNotEmpty) {
        profileImageUri = Uri.parse(response.url);
        print('로고 presigned URL API 호출 성공: ${response.url}');
      }
    } on DioException catch (e) {
      // DioException 타입별로 구체적인 오류 메시지 출력
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        print('로고 presigned URL API 호출 실패 (타임아웃): ${e.type}');
      } else if (e.type == DioExceptionType.badResponse) {
        print('로고 presigned URL API 호출 실패 (서버 오류): ${e.response?.statusCode}');
      } else if (e.type == DioExceptionType.connectionError) {
        print('로고 presigned URL API 호출 실패 (연결 오류): ${e.message}');
      } else {
        print('로고 presigned URL API 호출 실패: ${e.type} - ${e.message}');
      }
      // 실패 시 null로 설정 (카카오톡 기본 프로필 이미지 사용)
      profileImageUri = null;
    } catch (e) {
      print('로고 presigned URL API 호출 실패 (예외): $e');
      // 실패 시 null로 설정 (카카오톡 기본 프로필 이미지 사용)
      profileImageUri = null;
    }

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
        // S3에서 가져온 presigned URL 사용, 없으면 null (카카오톡 기본 프로필 이미지 사용)
        profileImageUrl: profileImageUri,
        // 메뉴 이미지가 있으면 사용, 없으면 null로 설정하여 표시하지 않음
        titleImageUrl:
            (gifticon.menu_url != null && gifticon.menu_url!.isNotEmpty)
                ? Uri.parse(gifticon.menu_url!)
                : null,
        // 메뉴 이름과 매장명 함께 표시
        titleImageText: gifticon.name,
        titleImageCategory:
            gifticon.store_name.isNotEmpty ? gifticon.store_name : null,
      ),
      buttons: [
        Button(
          title: '사용방법',
          link: Link(
            webUrl: Uri.parse(
                'https://jewel-bathtub-e52.notion.site/Gifnut-2e25f581503d803e9223f488367a9e3d?source=copy_link'),
            mobileWebUrl: Uri.parse(
                'https://jewel-bathtub-e52.notion.site/Gifnut-2e25f581503d803e9223f488367a9e3d?source=copy_link'),
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
