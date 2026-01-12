import 'package:json_annotation/json_annotation.dart';

part 'gifnut_image_url_response.g.dart';

@JsonSerializable()
class GifnutImageUrlResponse {
  String url;
  String bucket;
  @JsonKey(name: 'key')
  String objectKey;
  @JsonKey(name: 'expires_in')
  int expiresIn;
  @JsonKey(name: 'expires_in_hours')
  double expiresInHours;

  GifnutImageUrlResponse({
    required this.url,
    required this.bucket,
    required this.objectKey,
    required this.expiresIn,
    required this.expiresInHours,
  });

  factory GifnutImageUrlResponse.fromJson(Map<String, dynamic> json) =>
      _$GifnutImageUrlResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GifnutImageUrlResponseToJson(this);
}

