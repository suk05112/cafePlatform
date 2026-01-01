import 'package:json_annotation/json_annotation.dart';

part 'find_ownername_response.g.dart';

@JsonSerializable()
class FindOwnernameResponse {
  String? id;
  String? createdTime;
  String? msg;

  FindOwnernameResponse();

  factory FindOwnernameResponse.fromJson(Map<String, dynamic> json) =>
      _$FindOwnernameResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FindOwnernameResponseToJson(this);
}
