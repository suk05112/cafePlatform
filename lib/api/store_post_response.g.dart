// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_post_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorePostResponse _$StorePostResponseFromJson(Map<String, dynamic> json) =>
    StorePostResponse(
      store_id: json['store_id'] as int,
      store_logo_url: json['store_logo_url'] as String,
      store_photo_urls: (json['store_photo_urls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    )..presignedUrl = json['presignedUrl'] == null
        ? null
        : PresignedUrl.fromJson(json['presignedUrl'] as Map<String, dynamic>);

Map<String, dynamic> _$StorePostResponseToJson(StorePostResponse instance) =>
    <String, dynamic>{
      'store_id': instance.store_id,
      'store_logo_url': instance.store_logo_url,
      'store_photo_urls': instance.store_photo_urls,
      'presignedUrl': instance.presignedUrl,
    };

PresignedUrl _$PresignedUrlFromJson(Map<String, dynamic> json) => PresignedUrl(
      logo: json['logo'] as String?,
      storePhoto: (json['storePhoto'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PresignedUrlToJson(PresignedUrl instance) =>
    <String, dynamic>{
      'logo': instance.logo,
      'storePhoto': instance.storePhoto,
    };

StoreCardList _$StoreCardListFromJson(Map<String, dynamic> json) =>
    StoreCardList(
      storeList: (json['storeList'] as List<dynamic>)
          .map((e) => StoreCard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StoreCardListToJson(StoreCardList instance) =>
    <String, dynamic>{
      'storeList': instance.storeList,
    };

SearchStorePagination _$SearchStorePaginationFromJson(
        Map<String, dynamic> json) =>
    SearchStorePagination(
      cursor: json['cursor'] as int?,
      next_cursor: json['next_cursor'] as int?,
      limit: json['limit'] as int,
      has_next: json['has_next'] as bool,
    );

Map<String, dynamic> _$SearchStorePaginationToJson(
        SearchStorePagination instance) =>
    <String, dynamic>{
      'cursor': instance.cursor,
      'next_cursor': instance.next_cursor,
      'limit': instance.limit,
      'has_next': instance.has_next,
    };

SearchStoreGetResponse _$SearchStoreGetResponseFromJson(
        Map<String, dynamic> json) =>
    SearchStoreGetResponse(
      store: (json['store'] as List<dynamic>)
          .map((e) => StoreCard.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] == null
          ? null
          : SearchStorePagination.fromJson(
              json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SearchStoreGetResponseToJson(
        SearchStoreGetResponse instance) =>
    <String, dynamic>{
      'store': instance.store,
      'pagination': instance.pagination,
    };

NaverStoreResponse _$NaverStoreResponseFromJson(Map<String, dynamic> json) =>
    NaverStoreResponse(
      lastBuildDate: json['lastBuildDate'] as String,
      total: json['total'] as int,
      start: json['start'] as int,
      display: json['display'] as int,
      items: (json['items'] as List<dynamic>)
          .map((e) => StoreItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NaverStoreResponseToJson(NaverStoreResponse instance) =>
    <String, dynamic>{
      'lastBuildDate': instance.lastBuildDate,
      'total': instance.total,
      'start': instance.start,
      'display': instance.display,
      'items': instance.items,
    };

StoreItem _$StoreItemFromJson(Map<String, dynamic> json) => StoreItem(
      title: json['title'] as String,
      link: json['link'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      telephone: json['telephone'] as String,
      address: json['address'] as String,
      roadAddress: json['roadAddress'] as String,
      mapx: (json['mapx'] as num).toDouble(),
      mapy: (json['mapy'] as num).toDouble(),
    );

Map<String, dynamic> _$StoreItemToJson(StoreItem instance) => <String, dynamic>{
      'title': instance.title,
      'link': instance.link,
      'category': instance.category,
      'description': instance.description,
      'telephone': instance.telephone,
      'address': instance.address,
      'roadAddress': instance.roadAddress,
      'mapx': instance.mapx,
      'mapy': instance.mapy,
    };
