import 'dart:ffi';
import 'dart:convert';
import 'dart:io';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Order {
  int order_id;
  int store_id;
  int order_number;
  int price;
  String name;
  int status;

  Order(
      {this.order_id = 0,
      this.store_id = 0,
      this.order_number = 0,
      this.price = 0,
      this.name = "name not found",
      this.status = -1});
}
