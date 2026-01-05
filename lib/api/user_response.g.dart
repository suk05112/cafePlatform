// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterUserPostResponse _$RegisterUserPostResponseFromJson(
        Map<String, dynamic> json) =>
    RegisterUserPostResponse(
      user_id: json['user_id'] as int,
    );

Map<String, dynamic> _$RegisterUserPostResponseToJson(
        RegisterUserPostResponse instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
    };

LoginUserGetResponse _$LoginUserGetResponseFromJson(
        Map<String, dynamic> json) =>
    LoginUserGetResponse(
      user_id: json['user_id'] as int?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      phone_number: json['phone_number'] as String?,
      msg: json['msg'] as String?,
    );

Map<String, dynamic> _$LoginUserGetResponseToJson(
        LoginUserGetResponse instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'name': instance.name,
      'email': instance.email,
      'phone_number': instance.phone_number,
      'msg': instance.msg,
    };

IsRegisteredUserGetResponse _$IsRegisteredUserGetResponseFromJson(
        Map<String, dynamic> json) =>
    IsRegisteredUserGetResponse(
      isRegistered: json['isRegistered'] as bool,
    );

Map<String, dynamic> _$IsRegisteredUserGetResponseToJson(
        IsRegisteredUserGetResponse instance) =>
    <String, dynamic>{
      'isRegistered': instance.isRegistered,
    };

IsRegisteredAppleUserGetResponse _$IsRegisteredAppleUserGetResponseFromJson(
        Map<String, dynamic> json) =>
    IsRegisteredAppleUserGetResponse(
      isRegistered: json['isRegistered'] as bool,
    );

Map<String, dynamic> _$IsRegisteredAppleUserGetResponseToJson(
        IsRegisteredAppleUserGetResponse instance) =>
    <String, dynamic>{
      'isRegistered': instance.isRegistered,
    };

PushTokenRequest _$PushTokenRequestFromJson(Map<String, dynamic> json) =>
    PushTokenRequest(
      fcmToken: json['fcm_token'] as String,
      deviceType: json['device_type'] as String,
      allowServicePush: json['allow_service_push'] as bool,
      allowMarketingPush: json['allow_marketing_push'] as bool,
    );

Map<String, dynamic> _$PushTokenRequestToJson(PushTokenRequest instance) =>
    <String, dynamic>{
      'fcm_token': instance.fcmToken,
      'device_type': instance.deviceType,
      'allow_service_push': instance.allowServicePush,
      'allow_marketing_push': instance.allowMarketingPush,
    };

PushTokenUpdateRequest _$PushTokenUpdateRequestFromJson(
        Map<String, dynamic> json) =>
    PushTokenUpdateRequest(
      allowServicePush: json['allow_service_push'] as bool?,
      allowMarketingPush: json['allow_marketing_push'] as bool?,
    );

Map<String, dynamic> _$PushTokenUpdateRequestToJson(
        PushTokenUpdateRequest instance) =>
    <String, dynamic>{
      'allow_service_push': instance.allowServicePush,
      'allow_marketing_push': instance.allowMarketingPush,
    };
