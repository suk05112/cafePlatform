import 'dart:convert';
import 'dart:io';
import 'package:json_annotation/json_annotation.dart';

part 'menu.g.dart';

@JsonSerializable()
class MenuGetResponse {
  int statusCode;
  List<Menu> menuList;

  MenuGetResponse({required this.statusCode, required this.menuList});

  factory MenuGetResponse.fromJson(Map<String, dynamic> json) =>
      _$MenuGetResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MenuGetResponseToJson(this);
}

@JsonSerializable()
class MenuPostResponse {
  int statusCode;
  int menu_id;
  String menu_url;

  MenuPostResponse(
      {required this.statusCode,
      required this.menu_id,
      required this.menu_url});

  factory MenuPostResponse.fromJson(Map<String, dynamic> json) =>
      _$MenuPostResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MenuPostResponseToJson(this);
}

@JsonSerializable()
class Menu {
  int menu_id;
  int store_Id;
  String name;
  int price;
  String menu_image_url;
  String description;
  int status;

  Menu(
      {required this.menu_id,
      required this.store_Id,
      required this.name,
      required this.price,
      required this.menu_image_url,
      required this.description,
      required this.status});

  factory Menu.fromJson(Map<String, dynamic> json) => _$MenuFromJson(json);
  Map<String, dynamic> toJson() => _$MenuToJson(this);
}
