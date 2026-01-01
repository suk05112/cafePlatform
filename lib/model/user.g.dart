// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      user_id: (json['user_id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      phone_number: json['phone_number'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'user_id': instance.user_id,
      'name': instance.name,
      'email': instance.email,
      'phone_number': instance.phone_number,
    };
