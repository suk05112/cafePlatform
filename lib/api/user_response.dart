import 'package:json_annotation/json_annotation.dart';

part 'user_response.g.dart';

@JsonSerializable()
class RegisterUserPostResponse {
  @JsonKey(name: 'user_id')
  int userId;
  String? message;

  RegisterUserPostResponse({
    required this.userId,
    this.message,
  });

  factory RegisterUserPostResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterUserPostResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterUserPostResponseToJson(this);
}

@JsonSerializable()
class LoginUserGetResponse {
  @JsonKey(name: 'isRegistered')
  int? isRegistered;
  int? user_id;
  String? name;
  String? email;
  @JsonKey(name: 'phone_number')
  String? phone_number;
  String? msg;

  LoginUserGetResponse({
    this.isRegistered,
    this.user_id,
    this.email,
    this.name,
    this.phone_number,
    this.msg,
  });

  //  factory LoginResponse.fromJson(Map<String, dynamic> json) {
  //   return LoginResponse(
  //     statusCode: json["statusCode"],
  //     isRegistered: json["isRegistered"],
  //     userId: json["user_id"],
  //     name: json["name"],
  //     email: json["email"],
  //     phoneNumber: json["phone_number"],
  //     uid: json["uid"],
  //     msg: json["msg"],
  //   );
  // }

  factory LoginUserGetResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginUserGetResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginUserGetResponseToJson(this);
}

enum RegistrationStatus { newUser, phoneExists, registered }

@JsonSerializable()
class IsRegisteredUserGetResponse {
  String status;

  IsRegisteredUserGetResponse({required this.status});

  RegistrationStatus get registrationStatus {
    switch (status) {
      case 'registered':
        return RegistrationStatus.registered;
      case 'phone_exists':
        return RegistrationStatus.phoneExists;
      default:
        return RegistrationStatus.newUser;
    }
  }

  factory IsRegisteredUserGetResponse.fromJson(Map<String, dynamic> json) =>
      _$IsRegisteredUserGetResponseFromJson(json);
  Map<String, dynamic> toJson() => _$IsRegisteredUserGetResponseToJson(this);
}

@JsonSerializable()
class PushTokenRequest {
  @JsonKey(name: 'fcm_token')
  String fcmToken;

  @JsonKey(name: 'device_type')
  String deviceType;

  @JsonKey(name: 'allow_service_push')
  bool allowServicePush;

  @JsonKey(name: 'allow_marketing_push')
  bool allowMarketingPush;

  PushTokenRequest({
    required this.fcmToken,
    required this.deviceType,
    required this.allowServicePush,
    required this.allowMarketingPush,
  });

  factory PushTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$PushTokenRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PushTokenRequestToJson(this);
}

@JsonSerializable()
class PushTokenUpdateRequest {
  @JsonKey(name: 'allow_service_push')
  bool? allowServicePush;

  @JsonKey(name: 'allow_marketing_push')
  bool? allowMarketingPush;

  PushTokenUpdateRequest({
    this.allowServicePush,
    this.allowMarketingPush,
  });

  factory PushTokenUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$PushTokenUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PushTokenUpdateRequestToJson(this);
}

@JsonSerializable()
class DeleteUserResponse {
  String message;
  @JsonKey(name: 'user_id')
  int userId;
  @JsonKey(name: 'apple_revoked')
  bool? appleRevoked;

  DeleteUserResponse({
    required this.message,
    required this.userId,
    this.appleRevoked,
  });

  factory DeleteUserResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteUserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DeleteUserResponseToJson(this);
}

@JsonSerializable()
class PingUserResponse {
  String message;

  PingUserResponse({required this.message});

  factory PingUserResponse.fromJson(Map<String, dynamic> json) =>
      _$PingUserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PingUserResponseToJson(this);
}
