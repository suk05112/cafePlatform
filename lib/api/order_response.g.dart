// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderListResponse _$OrderListResponseFromJson(Map<String, dynamic> json) =>
    OrderListResponse(
      orderList: (json['order_list'] as List<dynamic>?)
              ?.map((e) => Order.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$OrderListResponseToJson(OrderListResponse instance) =>
    <String, dynamic>{
      'order_list': instance.orderList,
    };
