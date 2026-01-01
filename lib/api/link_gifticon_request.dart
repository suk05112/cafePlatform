import 'package:json_annotation/json_annotation.dart';

part 'link_gifticon_request.g.dart';

@JsonSerializable()
class LinkGifticonRequest {
  @JsonKey(name: 'user_id')
  int user_id;

  @JsonKey(name: 'gifticon_id')
  int gifticon_id;

  @JsonKey(name: 'receiver_phone')
  String receiver_phone;

  LinkGifticonRequest({
    required this.user_id,
    required this.gifticon_id,
    required this.receiver_phone,
  });

  factory LinkGifticonRequest.fromJson(Map<String, dynamic> json) =>
      _$LinkGifticonRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LinkGifticonRequestToJson(this);
}
