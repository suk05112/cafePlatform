// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      order_id: json['order_id'] as int,
      store_id: json['store_id'] as int,
      order_number: json['order_number'] as int,
      sender: json['sender'] as String,
      created_time: DateTime.parse(json['created_time'] as String),
      price: json['price'] as int,
      menu_name: json['menu_name'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'order_id': instance.order_id,
      'store_id': instance.store_id,
      'order_number': instance.order_number,
      'sender': instance.sender,
      'created_time': instance.created_time.toIso8601String(),
      'price': instance.price,
      'menu_name': instance.menu_name,
      'status': instance.status,
    };
