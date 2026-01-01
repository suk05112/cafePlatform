// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessInfoResponse _$BusinessInfoResponseFromJson(
        Map<String, dynamic> json) =>
    BusinessInfoResponse(
      business_number: json['business_number'] as String,
      online_sales_number: json['online_sales_number'] as String,
      address: json['address'] as String,
      telephone: json['telephone'] as String,
    );

Map<String, dynamic> _$BusinessInfoResponseToJson(
        BusinessInfoResponse instance) =>
    <String, dynamic>{
      'business_number': instance.business_number,
      'online_sales_number': instance.online_sales_number,
      'address': instance.address,
      'telephone': instance.telephone,
    };
