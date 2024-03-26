import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'find_ownername_response.g.dart';

@JsonSerializable()
class FindOwnernameResponse {
  int statusCode;
  String? id;
  String? createdTime;
  String? msg;

  FindOwnernameResponse({required this.statusCode});

  factory FindOwnernameResponse.fromJson(Map<String, dynamic> json) =>
      _$FindOwnernameResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FindOwnernameResponseToJson(this);
}
