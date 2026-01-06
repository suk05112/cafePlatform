import 'package:cafeplatform/api/gifticon_response.dart';
import 'package:cafeplatform/api/store_post_response.dart';
import 'package:cafeplatform/api/user_response.dart';
import 'package:cafeplatform/api/business_info_response.dart';
import 'package:cafeplatform/api/order_detail_response.dart';
import 'package:cafeplatform/api/link_gifticon_request.dart';
import 'package:cafeplatform/api/link_gifticon_response.dart';
import 'package:cafeplatform/model/Inquiry.dart';
import 'package:cafeplatform/model/Store.dart';
import 'package:cafeplatform/model/gifticon.dart';
import 'package:cafeplatform/model/menu.dart';
import 'package:cafeplatform/model/user.dart';
import 'package:cafeplatform/model/region.dart';
import 'package:cafeplatform/api/order_response.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'ApiClient.g.dart';

// @RestApi(baseUrl: "http://18.221.2.135")
@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // @GET("/home")
  // getHome();

  @POST("/user/register")
  Future<RegisterUserPostResponse> registerUser(@Body() User user);

  // @GET("/user/login/{email}")
  // Future<LoginUserGetResponse> loginUser(
  //   @Path('email') String email,
  // );

  @GET("/user/login/{email}")
  Future<LoginUserGetResponse> loginUser(
    @Path('email') String email,
  );

  @GET("/user/isRegistered")
  Future<IsRegisteredUserGetResponse> getIsRegisteredUser(
    @Query('email') String email,
    @Query('provider') String provider,
  );

  @GET("/user/isRegistered/{phoneNumber}")
  Future<IsRegisteredUserGetResponse> getIsRegisteredAppleUser(
    @Path('phoneNumber') String phoneNumber,
  );

  @GET("/store/info/{store_Id}")
  Future<StoreResponse> getStoreDetailInfo(
    @Path('store_Id') int storeId,
    // @Query("owner_id") int owner_id,
  );

  @GET("/store/list/")
  Future<StoreListResponse> getStoreList();

  @GET("/store/list/by-district/{district_code}")
  Future<StoreListResponse> getStoreListByDistrict(
    @Path('district_code') String districtCode,
    @Query('cursor') String? cursor,
    @Query('limit') int? limit,
  );

  @GET("/store/list/by-location")
  Future<StoreListResponse> getStoreListByLocation(
    @Query('lat') double lat,
    @Query('lng') double lng,
  );

  @GET("/store/search")
  Future<SearchStoreGetResponse> searchStoreByQuery(
    @Query('query') String query,
    @Query('cursor') int? cursor,
    @Query('limit') int? limit,
  );
  @GET("/menu/list/{store_id}")
  Future<MenuGetResponse> getMenuList(
    @Path('store_id') int storeId,
  );

  @POST("/menu/")
  Future<MenuPostResponse> addMenu(
    @Body() Menu menu,
  );

  @GET("/gifticon/list/{user_id}")
  Future<GifticonListResponse> getGifticonList(
    @Path('user_id') int userId,
  );

  @POST("/order/{user_id}")
  Future<PurchaseGifticonResponse> purchaseGifticon(
    @Path('user_id') int userId,
    @Body() Gifticon gifticon,
  );

  @POST("/order/payment/result")
  Future<void> sendPaymentResult(
    @Body() PaymentResultRequest paymentResult,
  );

  @GET("/gifticon/{gifticon_id}")
  Future<GetGifticonResponse> getGifticon(
    @Path('gifticon_id') int gifticonId,
  );

  @GET("/order/refund/{order_id}")
  Future<void> refundGifticon(
    @Path('order_id') int orderId,
  );

  @GET("/order/list/{user_id}")
  Future<OrderListResponse> getOrderList(
    @Path('user_id') int userId,
  );

  @GET("/order/detail/{order_id}")
  Future<GetOrderDetailResponse> getOrderDetail(
    @Path('order_id') int orderId,
  );

  @POST("/user/inquiry/{user_id}")
  Future<InquiryPostResponse> subjectInquiry(
    @Path('user_id') int userId,
    @Body() Inquiry inquiry,
  );

  @GET("/user/inquiry/{user_id}")
  Future<InquiryListResponse> getInquiry(
    @Path('user_id') int userId,
  );

  @GET("/store/regions-districts")
  Future<RegionListResponse> getAvailableRegions();

  @POST("/user/push-token/{user_id}")
  Future<void> registerPushToken(
    @Path('user_id') int userId,
    @Body() PushTokenRequest pushTokenRequest,
  );

  @PATCH("/user/push-token/{user_id}")
  Future<void> updatePushToken(
    @Path('user_id') int userId,
    @Body() PushTokenUpdateRequest pushTokenUpdateRequest,
    @Header('X-FCM-Token') String? fcmToken,
  );

  @GET("/business-info")
  Future<BusinessInfoResponse> getBusinessInfo();

  @POST("/gifticon/link")
  Future<LinkGifticonResponse> linkGifticonToUser(
    @Body() LinkGifticonRequest request,
  );
}
