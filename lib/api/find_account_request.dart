import 'package:json_annotation/json_annotation.dart';

part 'find_account_request.g.dart';

@JsonSerializable()
class FindAccountRequest {
  final String name;
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  final String type; // "find_id" or "find_password"

  FindAccountRequest({
    required this.name,
    required this.phoneNumber,
    required this.type,
  });

  factory FindAccountRequest.fromJson(Map<String, dynamic> json) =>
      _$FindAccountRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FindAccountRequestToJson(this);
}

