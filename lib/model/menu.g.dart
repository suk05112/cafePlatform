// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuGetResponse _$MenuGetResponseFromJson(Map<String, dynamic> json) =>
    MenuGetResponse(
      menuList: (json['menuList'] as List<dynamic>)
          .map((e) => Menu.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MenuGetResponseToJson(MenuGetResponse instance) =>
    <String, dynamic>{
      'menuList': instance.menuList,
    };

MenuPostResponse _$MenuPostResponseFromJson(Map<String, dynamic> json) =>
    MenuPostResponse(
      menu_id: (json['menu_id'] as num).toInt(),
      menu_url: json['menu_url'] as String,
    );

Map<String, dynamic> _$MenuPostResponseToJson(MenuPostResponse instance) =>
    <String, dynamic>{
      'menu_id': instance.menu_id,
      'menu_url': instance.menu_url,
    };

Menu _$MenuFromJson(Map<String, dynamic> json) => Menu(
      menu_id: (json['menu_id'] as num).toInt(),
      store_id: (json['store_id'] as num).toInt(),
      name: json['name'] as String?,
      price: (json['price'] as num).toInt(),
      menu_image_url: json['menu_image_url'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$MenuToJson(Menu instance) => <String, dynamic>{
      'menu_id': instance.menu_id,
      'store_id': instance.store_id,
      'name': instance.name,
      'price': instance.price,
      'menu_image_url': instance.menu_image_url,
      'description': instance.description,
      'status': instance.status,
    };
