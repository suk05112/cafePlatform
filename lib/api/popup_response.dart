import 'package:json_annotation/json_annotation.dart';

part 'popup_response.g.dart';

@JsonSerializable()
class PopupItem {
  int id;
  String title;

  @JsonKey(name: 'image_url')
  String imageUrl;

  @JsonKey(name: 'link_url')
  String? linkUrl;

  @JsonKey(name: 'display_order')
  int displayOrder;

  PopupItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkUrl,
    required this.displayOrder,
  });

  factory PopupItem.fromJson(Map<String, dynamic> json) =>
      _$PopupItemFromJson(json);
  Map<String, dynamic> toJson() => _$PopupItemToJson(this);
}

@JsonSerializable()
class PopupListResponse {
  String message;
  List<PopupItem> data;

  PopupListResponse({
    required this.message,
    required this.data,
  });

  factory PopupListResponse.fromJson(Map<String, dynamic> json) =>
      _$PopupListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PopupListResponseToJson(this);
}
