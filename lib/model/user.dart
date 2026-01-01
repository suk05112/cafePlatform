import 'package:json_annotation/json_annotation.dart';

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

  User({
    required this.user_id,
    required this.name,
    required this.email,
    required this.phone_number,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
