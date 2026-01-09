// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_account_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FindAccountRequest _$FindAccountRequestFromJson(Map<String, dynamic> json) =>
    FindAccountRequest(
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$FindAccountRequestToJson(FindAccountRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phone_number': instance.phoneNumber,
      'type': instance.type,
    };
