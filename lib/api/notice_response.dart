import 'package:json_annotation/json_annotation.dart';

part 'notice_response.g.dart';

@JsonSerializable()
class NoticeListItem {
  int id;
  String title;

  @JsonKey(name: 'created_at')
  String created_at;

  NoticeListItem({
    required this.id,
    required this.title,
    required this.created_at,
  });

  factory NoticeListItem.fromJson(Map<String, dynamic> json) =>
      _$NoticeListItemFromJson(json);
  Map<String, dynamic> toJson() => _$NoticeListItemToJson(this);
}

@JsonSerializable()
class NoticePagination {
  int total;
  int page;
  int limit;

  @JsonKey(name: 'total_pages')
  int total_pages;

  NoticePagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.total_pages,
  });

  factory NoticePagination.fromJson(Map<String, dynamic> json) =>
      _$NoticePaginationFromJson(json);
  Map<String, dynamic> toJson() => _$NoticePaginationToJson(this);
}

@JsonSerializable()
class UserNoticeListResponse {
  String message;
  List<NoticeListItem> data;
  NoticePagination pagination;

  UserNoticeListResponse({
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory UserNoticeListResponse.fromJson(Map<String, dynamic> json) =>
      _$UserNoticeListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserNoticeListResponseToJson(this);
}

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
class UserNoticeDetailResponse {
  String message;
  UserNotice data;

  UserNoticeDetailResponse({
    required this.message,
    required this.data,
  });

  factory UserNoticeDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$UserNoticeDetailResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserNoticeDetailResponseToJson(this);
}
