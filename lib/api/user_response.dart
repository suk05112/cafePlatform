import 'package:json_annotation/json_annotation.dart';

part 'user_response.g.dart';

@JsonSerializable()
class RegisterUserPostResponse {
  int user_id;

  RegisterUserPostResponse({required this.user_id});

  factory RegisterUserPostResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterUserPostResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterUserPostResponseToJson(this);
}

@JsonSerializable()
class LoginUserGetResponse {
  int? user_id;
  String? name;
  String? email;
  String? phone_number;
  String? msg;

  LoginUserGetResponse({
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

@JsonSerializable()
class IsRegisteredUserGetResponse {
  bool isRegistered;

  IsRegisteredUserGetResponse({required this.isRegistered});

  factory IsRegisteredUserGetResponse.fromJson(Map<String, dynamic> json) =>
      _$IsRegisteredUserGetResponseFromJson(json);
  Map<String, dynamic> toJson() => _$IsRegisteredUserGetResponseToJson(this);
}

@JsonSerializable()
class IsRegisteredAppleUserGetResponse {
  bool isRegistered;

  IsRegisteredAppleUserGetResponse({required this.isRegistered});

  factory IsRegisteredAppleUserGetResponse.fromJson(
          Map<String, dynamic> json) =>
      _$IsRegisteredAppleUserGetResponseFromJson(json);
  Map<String, dynamic> toJson() =>
      _$IsRegisteredAppleUserGetResponseToJson(this);
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
