// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      order_id: json['order_id'] as int,
      store_id: json['store_id'] as int,
      order_number: json['order_number'] as String,
      sender: json['sender'] as String,
      created_time: Order._dateTimeFromJson(json['created_time']),
      price: json['price'] as int,
      menu_name: json['menu_name'] as String,
      menu_url: json['menu_url'] as String?,
      status: json['status'] as String,
      product_type: json['product_type'] as String?,
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'order_id': instance.order_id,
      'store_id': instance.store_id,
      'order_number': instance.order_number,
      'sender': instance.sender,
      'created_time': instance.created_time.toIso8601String(),
      'price': instance.price,
      'menu_name': instance.menu_name,
      'menu_url': instance.menu_url,
      'status': instance.status,
      'product_type': instance.product_type,
    };
