import 'package:json_annotation/json_annotation.dart';

part 'Inquiry.g.dart';

@JsonSerializable()
class Inquiry {
  String title;
  String content;

  Inquiry({
    required this.title,
    required this.content,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) =>
      _$InquiryFromJson(json);
  Map<String, dynamic> toJson() => _$InquiryToJson(this);
}

@JsonSerializable()
class InquiryPostResponse {
  InquiryPostResponse();

  factory InquiryPostResponse.fromJson(Map<String, dynamic> json) =>
      _$InquiryPostResponseFromJson(json);
  Map<String, dynamic> toJson() => _$InquiryPostResponseToJson(this);
}

@JsonSerializable()
class InquiryResponse {
  String title;
  String content;
  String? response;
  String status;
  DateTime inquiry_created;
  DateTime? response_created;

  InquiryResponse({
    required this.title,
    required this.content,
    this.response,
    required this.status,
    required this.inquiry_created,
    this.response_created,
  });

  factory InquiryResponse.fromJson(Map<String, dynamic> json) =>
      _$InquiryResponseFromJson(json);
  Map<String, dynamic> toJson() => _$InquiryResponseToJson(this);
}

@JsonSerializable()
class InquiryListResponse {
  @JsonKey(name: "inquiry_list")
  List<InquiryResponse> inquiryResponse = [];

  InquiryListResponse({required this.inquiryResponse});

  factory InquiryListResponse.fromJson(Map<String, dynamic> json) =>
      _$InquiryListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$InquiryListResponseToJson(this);
}
