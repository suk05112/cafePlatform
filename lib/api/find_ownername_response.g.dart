// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_ownername_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FindOwnernameResponse _$FindOwnernameResponseFromJson(
        Map<String, dynamic> json) =>
    FindOwnernameResponse()
      ..id = json['id'] as String?
      ..createdTime = json['createdTime'] as String?
      ..msg = json['msg'] as String?;

Map<String, dynamic> _$FindOwnernameResponseToJson(
        FindOwnernameResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdTime': instance.createdTime,
      'msg': instance.msg,
    };
