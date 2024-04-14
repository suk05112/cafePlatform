import 'package:my_app/api/find_ownername_response.dart';
import 'package:my_app/api/store_post_response.dart';
import 'package:my_app/model/Store.dart';
import 'package:my_app/model/menu.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
part 'ApiClient.g.dart';

@RestApi(baseUrl: "http://18.221.2.135")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // @GET("/home")
  // getHome();

  @GET("/store/{store_Id}")
  Future<StoreResponse> getStoreDetailInfo(
    @Path('store_Id') int store_Id,
    // @Query("owner_id") int owner_id,
  );

  @GET("/store/list/{owner_id}")
  Future<StoreListResponse> getStoreList(
    @Path('owner_id') int owner_id,
  );

  @POST("/store/")
  Future<StorePostResponse> registerStore(
    @Body() Store store,
  );

  @POST("owner/find_username")
  Future<FindOwnernameResponse> findOwnername(
    @Body() String uid,
  );

  @GET("/menu/list/{store_id}")
  Future<MenuGetResponse> getMenuList(
    @Path('store_id') int store_id,
  );

  @POST("/menu/")
  Future<MenuPostResponse> addMenu(
    @Body() Menu menu,
  );
}
