import 'package:json_annotation/json_annotation.dart';

part 'region.g.dart';

@JsonSerializable()
class District {
  String district_code;
  String district_name;

  District({
    required this.district_code,
    required this.district_name,
  });

  factory District.fromJson(Map<String, dynamic> json) =>
      _$DistrictFromJson(json);
  Map<String, dynamic> toJson() => _$DistrictToJson(this);
}

@JsonSerializable()
class Region {
  String region_name;
  String region_code;
  String? district_name;
  String? district_code;
  List<District>? districts;

  Region({
    required this.region_name,
    required this.region_code,
    this.district_name,
    this.district_code,
    this.districts,
  });

  factory Region.fromJson(Map<String, dynamic> json) => _$RegionFromJson(json);
  Map<String, dynamic> toJson() => _$RegionToJson(this);
}

@JsonSerializable()
class RegionListResponse {
  List<Region> regions;

  RegionListResponse({
    required this.regions,
  });

  factory RegionListResponse.fromJson(Map<String, dynamic> json) =>
      _$RegionListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RegionListResponseToJson(this);
}
