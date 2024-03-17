import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:my_app/model/Store';
part 'ApiClient.g.dart';

@RestApi(
    baseUrl: "https://ot113tt778.execute-api.us-east-2.amazonaws.com/staging")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // @GET("/store/{store_Id}")
  // Future<StoreResponse> getStoreDetailInfo(
  //   @Path('store_Id') int store_Id,
  //   // @Query("owner_id") int owner_id,
  // );

  @GET("/store/list/{owner_id}")
  Future<StoreListResponse> getStoreList(
    @Path('owner_id') int owner_id,
  );

  // @POST("/store/")
  // Future<StorePostResponse> registerStore(
  //   @Body() Store store,
  // );

  // @POST("owner/find_username")
  // Future<FindOwnernameResponse> findOwnername(
  //   @Body() String uid,
  // );

  // @GET("/menu/list/{store_Id}")
  // Future<MenuGetResponse> getMenuList(
  //   @Path('store_Id') int store_Id,
  // );

  // @POST("/menu/")
  // Future<MenuPostResponse> addMenu(
  //   @Body() Menu menu,
  // );
}
