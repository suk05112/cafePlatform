// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      user_id: json['user_id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone_number: json['phone_number'] as String,
      uid: json['uid'] as String,
      provider: json['provider'] as String?,
      agreements: User._agreementsFromJson(json['agreements']),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'user_id': instance.user_id,
      'name': instance.name,
      'email': instance.email,
      'phone_number': instance.phone_number,
      'uid': instance.uid,
      'provider': instance.provider,
      'agreements': User._agreementsToJson(instance.agreements),
    };
