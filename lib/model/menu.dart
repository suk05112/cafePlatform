import 'package:json_annotation/json_annotation.dart';

part 'menu.g.dart';

class RecommendMenu {
  final int storeId;
  final String storeName;
  final String storeLogo;
  final int menuId;
  final String menuName;
  final int price;
  final String? description;
  final String? menuPhoto;
  final double? distance;

  const RecommendMenu({
    required this.storeId,
    required this.storeName,
    required this.storeLogo,
    required this.menuId,
    required this.menuName,
    required this.price,
    this.description,
    this.menuPhoto,
    this.distance,
  });

  factory RecommendMenu.fromJson(Map<String, dynamic> json) => RecommendMenu(
        storeId: (json['store_id'] as num?)?.toInt() ?? 0,
        storeName: json['store_name'] as String? ?? '',
        storeLogo: json['store_logo'] as String? ?? '',
        menuId: (json['menu_id'] as num?)?.toInt() ?? 0,
        menuName: json['menu_name'] as String? ?? '',
        price: (json['price'] as num?)?.toInt() ?? 0,
        description: json['description'] as String?,
        menuPhoto: json['menu_photo'] as String?,
        distance: (json['distance'] as num?)?.toDouble(),
      );
}

class RecommendMenuResponse {
  final List<RecommendMenu> menuList;
  final String? nextCursor;
  final bool hasNext;

  const RecommendMenuResponse({
    required this.menuList,
    this.nextCursor,
    required this.hasNext,
  });

  factory RecommendMenuResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['menuList'] as List<dynamic>? ?? [])
        .map((e) => RecommendMenu.fromJson(e as Map<String, dynamic>))
        .toList();
    return RecommendMenuResponse(
      menuList: list,
      nextCursor: json['next_cursor'] as String?,
      hasNext: json['has_next'] as bool? ?? false,
    );
  }
}

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
