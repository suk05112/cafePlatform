import 'package:json_annotation/json_annotation.dart';

part 'notice_response.g.dart';

@JsonSerializable()
class UserNotice {
  int id;
  String title;
  String content;
  
  @JsonKey(name: 'created_at')
  String created_at;
  
  @JsonKey(name: 'updated_at')
  String? updated_at;

  UserNotice({
    required this.id,
    required this.title,
    required this.content,
    required this.created_at,
    this.updated_at,
  });

  factory UserNotice.fromJson(Map<String, dynamic> json) =>
      _$UserNoticeFromJson(json);
  Map<String, dynamic> toJson() => _$UserNoticeToJson(this);
}

@JsonSerializable()
class UserNoticeListResponse {
  @JsonKey(defaultValue: [])
  List<UserNotice> notices;
  int total;

  UserNoticeListResponse({
    required this.notices,
    required this.total,
  });

  factory UserNoticeListResponse.fromJson(Map<String, dynamic> json) =>
      _$UserNoticeListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserNoticeListResponseToJson(this);
}

