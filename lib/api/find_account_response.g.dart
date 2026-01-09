// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_account_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FindAccountResponse _$FindAccountResponseFromJson(Map<String, dynamic> json) =>
    FindAccountResponse(
      success: json['success'] as bool,
      type: json['type'] as String,
      email: json['email'] as String?,
      fullEmail: json['full_email'] as String?,
      verified: json['verified'] as bool?,
      message: json['message'] as String,
    );

Map<String, dynamic> _$FindAccountResponseToJson(
        FindAccountResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'type': instance.type,
      'email': instance.email,
      'full_email': instance.fullEmail,
      'verified': instance.verified,
      'message': instance.message,
    };
