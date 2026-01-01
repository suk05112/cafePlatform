// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'region.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

District _$DistrictFromJson(Map<String, dynamic> json) => District(
      district_code: json['district_code'] as String,
      district_name: json['district_name'] as String,
    );

Map<String, dynamic> _$DistrictToJson(District instance) => <String, dynamic>{
      'district_code': instance.district_code,
      'district_name': instance.district_name,
    };

Region _$RegionFromJson(Map<String, dynamic> json) => Region(
      region_name: json['region_name'] as String,
      region_code: json['region_code'] as String,
      district_name: json['district_name'] as String?,
      district_code: json['district_code'] as String?,
      districts: (json['districts'] as List<dynamic>?)
          ?.map((e) => District.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RegionToJson(Region instance) => <String, dynamic>{
      'region_name': instance.region_name,
      'region_code': instance.region_code,
      'district_name': instance.district_name,
      'district_code': instance.district_code,
      'districts': instance.districts,
    };

RegionListResponse _$RegionListResponseFromJson(Map<String, dynamic> json) =>
    RegionListResponse(
      regions: (json['regions'] as List<dynamic>)
          .map((e) => Region.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RegionListResponseToJson(RegionListResponse instance) =>
    <String, dynamic>{
      'regions': instance.regions,
    };
