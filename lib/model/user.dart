import 'package:json_annotation/json_annotation.dart';
import 'package:cafeplatform/api/terms_agree_request.dart';

part 'user.g.dart';

// @JsonSerializable()
// class UserGetResponse {
//   int statusCode;
//   List<User> menuList;

//   UserGetResponse({required this.statusCode, required this.menuList});

//   factory UserGetResponse.fromJson(Map<String, dynamic> json) =>
//       _$UserGetResponseFromJson(json);
//   Map<String, dynamic> toJson() => _$UserGetResponseToJson(this);
// }

@JsonSerializable()
class User {
  int user_id;
  String name;
  String email;
  String phone_number;
  String uid;
  String? provider;
  @JsonKey(toJson: _agreementsToJson, fromJson: _agreementsFromJson)
  List<TermAgreementItem>? agreements;

  User({
    required this.user_id,
    required this.name,
    required this.email,
    required this.phone_number,
    required this.uid,
    this.provider,
    this.agreements,
  });

  static List<Map<String, dynamic>>? _agreementsToJson(
          List<TermAgreementItem>? agreements) =>
      agreements?.map((e) => e.toJson()).toList();

  static List<TermAgreementItem>? _agreementsFromJson(dynamic json) => null;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
