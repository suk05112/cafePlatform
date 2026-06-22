import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cafeplatform/config/flavors.dart';

/// S3 presigned URL 생성을 위한 헬퍼 클래스
/// AWS Signature Version 4 알고리즘을 사용하여 presigned URL 생성
class S3PresignedUrlHelper {
  // S3 버킷 설정 (flavor에 따라 dev/prod 버킷 분기)
  static String get bucketName =>
      F.appFlavor == Flavor.prod ? 'cafeplatform' : 'cafeplatform-dev';

  static const String region = 'ap-northeast-2';
  static const String service = 's3';

  // AWS 자격 증명 (실제 운영 시에는 환경 변수나 secure storage에서 가져와야 함)
  // TODO: 실제 AWS Access Key와 Secret Key를 환경 변수나 secure storage에서 관리하세요
  static const String accessKeyId = 'AKIAQD4W7YEDZS7TU7NB';
  static const String secretAccessKey =
      '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'; // 실제 Secret Key로 변경 필요

  /// S3 객체에 대한 presigned URL 생성
  ///
  /// [objectKey] S3 객체 키 (예: 'gifnut-logo.png')
  /// [expirationMinutes] URL 만료 시간 (분), 기본값: 60분
  static String generatePresignedUrl(
    String objectKey, {
    int expirationMinutes = 60,
  }) {
    try {
      final now = DateTime.now().toUtc();
      final expirationSeconds = expirationMinutes * 60;
      final amzDate = _formatDateTime(now);
      final dateStamp = amzDate.substring(0, 8);

      // Object key의 각 세그먼트를 인코딩 (슬래시는 유지)
      // 예: "folder/subfolder/file.png" -> "folder/subfolder/file.png" (세그먼트별로 인코딩)
      final pathSegments = objectKey.split('/');
      final encodedPathSegments =
          pathSegments.map((segment) => Uri.encodeComponent(segment)).join('/');
      final canonicalUri = '/$encodedPathSegments';

      // 쿼리 파라미터 구성 (credential의 슬래시는 URL 인코딩해야 함)
      final credentialScope = '$dateStamp/$region/$service/aws4_request';
      final credential = '$accessKeyId/$credentialScope';

      // 쿼리 파라미터를 정렬해서 생성 (AWS 요구사항)
      final queryParams = <String, String>{
        'X-Amz-Algorithm': 'AWS4-HMAC-SHA256',
        'X-Amz-Credential': credential,
        'X-Amz-Date': amzDate,
        'X-Amz-Expires': expirationSeconds.toString(),
        'X-Amz-SignedHeaders': 'host',
      };

      // Canonical query string 생성 (정렬된 순서로)
      final sortedQueryParams = queryParams.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      final canonicalQueryString = sortedQueryParams
          .map((e) =>
              '${_uriEncode(e.key, encodeSlash: false)}=${_uriEncode(e.value, encodeSlash: false)}')
          .join('&');

      // Canonical headers
      final canonicalHeaders = 'host:$bucketName.s3.$region.amazonaws.com\n';
      final signedHeaders = 'host';

      // Payload hash (GET 요청이므로 빈 문자열)
      final hashedPayload = sha256.convert(utf8.encode('')).toString();

      // Canonical request
      final canonicalRequest =
          'GET\n$canonicalUri\n$canonicalQueryString\n$canonicalHeaders\n$signedHeaders\n$hashedPayload';

      // String to sign
      final hashedCanonicalRequest =
          sha256.convert(utf8.encode(canonicalRequest)).toString();
      final stringToSign =
          'AWS4-HMAC-SHA256\n$amzDate\n$credentialScope\n$hashedCanonicalRequest';

      // 서명 생성
      final kDate = _hmacSha256(
          utf8.encode('AWS4$secretAccessKey'), utf8.encode(dateStamp));
      final kRegion = _hmacSha256(kDate, utf8.encode(region));
      final kService = _hmacSha256(kRegion, utf8.encode(service));
      final kSigning = _hmacSha256(kService, utf8.encode('aws4_request'));
      final signatureBytes = _hmacSha256(kSigning, utf8.encode(stringToSign));
      final signature =
          signatureBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

      // 최종 쿼리 파라미터에 서명 추가
      queryParams['X-Amz-Signature'] = signature;

      // 최종 쿼리 문자열 생성 (다시 정렬)
      final finalQueryParams = queryParams.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      final queryString = finalQueryParams
          .map((e) =>
              '${_uriEncode(e.key, encodeSlash: false)}=${_uriEncode(e.value, encodeSlash: false)}')
          .join('&');

      return 'https://$bucketName.s3.$region.amazonaws.com$canonicalUri?$queryString';
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  /// URI 인코딩 헬퍼 (AWS 요구사항에 맞게)
  static String _uriEncode(String value, {bool encodeSlash = true}) {
    final encoded = Uri.encodeComponent(value);
    if (!encodeSlash) {
      // 슬래시는 인코딩하지 않음 (쿼리 파라미터 값의 경우)
      return encoded.replaceAll('%2F', '/');
    }
    return encoded;
  }

  /// 로고 이미지의 presigned URL 생성
  static String generateLogoPresignedUrl({int expirationMinutes = 60}) {
    return generatePresignedUrl(
      'gifnut-logo.png',
      expirationMinutes: expirationMinutes,
    );
  }

  /// DateTime을 AWS 요구 형식으로 포맷팅 (YYYYMMDDTHHMMSSZ)
  static String _formatDateTime(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '${year}${month}${day}T${hour}${minute}${second}Z';
  }

  /// HMAC-SHA256 해시 생성
  static Uint8List _hmacSha256(List<int> key, List<int> data) {
    final hmac = Hmac(sha256, key);
    return Uint8List.fromList(hmac.convert(data).bytes);
  }
}
