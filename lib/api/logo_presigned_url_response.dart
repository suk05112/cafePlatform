import 'package:json_annotation/json_annotation.dart';

part 'logo_presigned_url_response.g.dart';

@JsonSerializable()
class LogoPresignedUrlResponse {
  @JsonKey(name: 'presigned_url')
  String presignedUrl;

  LogoPresignedUrlResponse({
    required this.presignedUrl,
  });

  factory LogoPresignedUrlResponse.fromJson(Map<String, dynamic> json) =>
      _$LogoPresignedUrlResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LogoPresignedUrlResponseToJson(this);
}
