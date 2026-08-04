import 'package:json_annotation/json_annotation.dart';

part 'app_version_response.g.dart';

@JsonSerializable()
class AppVersionResponse {
  String? version;

  @JsonKey(name: 'is_force_update')
  bool isForceUpdate;

  AppVersionResponse({
    this.version,
    required this.isForceUpdate,
  });

  factory AppVersionResponse.fromJson(Map<String, dynamic> json) =>
      _$AppVersionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AppVersionResponseToJson(this);
}
