import 'package:cafeplatform/model/Store.dart';
import 'package:cafeplatform/model/menu.dart';

class StoreDummyRepository {
  static final List<Store> stores = [
    Store(
      store_id: -1,
      store_name: "시청 더블샷",
      store_address: "서울특별시 중구 세종대로 110",
      store_lat: 37.5663,
      store_lng: 126.9779,
      store_description: "서울 도심이 내려다보이는 스페셜티 카페",
      store_logo: "logo_test",
      isDummy: true,
    ),
    Store(
      store_id: -2,
      store_name: "강남 브랜치",
      store_address: "서울특별시 강남구 테헤란로 231",
      store_lat: 37.5013,
      store_lng: 127.0396,
      store_description: "",
      store_logo: "logo_test",
      isDummy: true,
    ),
    Store(
      store_id: -3,
      store_name: "성수 한강뷰",
      store_address: "서울특별시 성동구 왕십리로 83",
      store_lat: 37.5430,
      store_lng: 127.0550,
      store_description: "루프탑에서 즐기는 디저트와 드립커피",
      store_logo: "logo_test",
      isDummy: true,
    ),
  ];
}

class MenuDummyRepository {
  static final List<Menu> menus = [
    Menu(
        menu_id: -1,
        store_id: -1,
        name: "아메리카노",
        price: 3500,
        menu_image_url:
            "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80",
        description: "진한 에스프레소에 뜨거운 물을 더해 부드럽고 깔끔한 맛",
        status: "ACTIVE"),
    Menu(
        menu_id: -2,
        store_id: -1,
        name: "카페라떼",
        price: 4000,
        menu_image_url:
            "https://images.unsplash.com/photo-1528825871115-3581a5387919?auto=format&fit=crop&w=400&q=80",
        description: "",
        status: "ACTIVE"),
    Menu(
        menu_id: -3,
        store_id: -1,
        name: "바닐라라떼",
        price: 4500,
        menu_image_url:
            "https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80",
        description: "달콤한 바닐라와 라떼의 조화",
        status: "ACTIVE"),
  ];
}
