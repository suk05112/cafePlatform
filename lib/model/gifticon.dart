import 'dart:ffi';
import 'dart:convert';
import 'dart:io';
import 'package:json_annotation/json_annotation.dart';

part 'gifticon.g.dart';

@JsonSerializable()
class Gifticon {
  int order_id;
  String name;
  int price;
  String description;
  DateTime? validity;
  String sender;
  String receiver;
  int use_yn;
  int availability;
  String menu_url;

  // Gifticon({this.order_id = 0,});
  Gifticon({
    this.order_id = 0,
    this.name = "",
    this.price = 0,
    this.description = "",
    // this.validity = DateTime(2020, 1, 1, 1, 1),
    this.sender = "",
    this.receiver = "",
    this.use_yn = 1,
    this.availability = 0,
    this.menu_url = "",
  });

  factory Gifticon.fromJson(Map<String, dynamic> json) =>
      _$GifticonFromJson(json);
  Map<String, dynamic> toJson() => _$GifticonToJson(this);
}

@JsonSerializable()
class GifticonListResponse {
  int statusCode;
  List<Gifticon> gifticonList;

  GifticonListResponse({required this.statusCode, required this.gifticonList});

  factory GifticonListResponse.fromJson(Map<String, dynamic> json) =>
      _$GifticonListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GifticonListResponseToJson(this);
}
