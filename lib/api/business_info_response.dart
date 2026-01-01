import 'package:json_annotation/json_annotation.dart';

part 'business_info_response.g.dart';

@JsonSerializable()
class BusinessInfoResponse {
  @JsonKey(name: 'business_number')
  String business_number;

  @JsonKey(name: 'online_sales_number')
  String online_sales_number;

  String address;

  String telephone;

  BusinessInfoResponse({
    required this.business_number,
    required this.online_sales_number,
    required this.address,
    required this.telephone,
  });

  factory BusinessInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$BusinessInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BusinessInfoResponseToJson(this);
}
