import 'package:json_annotation/json_annotation.dart';

part 'link_gifticon_response.g.dart';

@JsonSerializable()
class LinkGifticonResponse {
  String message;

  @JsonKey(name: 'gifticon_id')
  int gifticon_id;

  @JsonKey(name: 'user_id')
  int user_id;

  LinkGifticonResponse({
    required this.message,
    required this.gifticon_id,
    required this.user_id,
  });

  factory LinkGifticonResponse.fromJson(Map<String, dynamic> json) =>
      _$LinkGifticonResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LinkGifticonResponseToJson(this);
}
