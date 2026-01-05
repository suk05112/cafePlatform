import 'package:json_annotation/json_annotation.dart';

part 'menu.g.dart';

@JsonSerializable()
class MenuGetResponse {
  List<Menu> menuList;

  MenuGetResponse({required this.menuList});

  factory MenuGetResponse.fromJson(Map<String, dynamic> json) =>
      _$MenuGetResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MenuGetResponseToJson(this);
}

@JsonSerializable()
class MenuPostResponse {
  int menu_id;
  String menu_url;

  MenuPostResponse({required this.menu_id, required this.menu_url});

  factory MenuPostResponse.fromJson(Map<String, dynamic> json) =>
      _$MenuPostResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MenuPostResponseToJson(this);
}

@JsonSerializable()
class Menu {
  int menu_id;
  int store_id;
  @JsonKey(name: 'menu_name')
  String? name;
  int price;
  @JsonKey(name: 'menu_photo')
  String? menu_image_url;
  String? description;
  String? status;

  Menu(
      {this.menu_id = 0,
      this.store_id = 0,
      this.name,
      this.price = 0,
      this.menu_image_url,
      this.description,
      this.status});

  factory Menu.fromJson(Map<String, dynamic> json) => _$MenuFromJson(json);
  Map<String, dynamic> toJson() => _$MenuToJson(this);
}
