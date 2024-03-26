// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_ownername_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FindOwnernameResponse _$FindOwnernameResponseFromJson(
        Map<String, dynamic> json) =>
    FindOwnernameResponse(
      statusCode: json['statusCode'] as int,
    )
      ..id = json['id'] as String?
      ..createdTime = json['createdTime'] as String?
      ..msg = json['msg'] as String?;

Map<String, dynamic> _$FindOwnernameResponseToJson(
        FindOwnernameResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'id': instance.id,
      'createdTime': instance.createdTime,
      'msg': instance.msg,
    };
