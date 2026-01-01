import 'package:flutter/material.dart';
import 'package:cafeplatform/Extension/datetime_extension.dart';
import 'package:cafeplatform/model/order.dart';
import 'package:cafeplatform/order/order_detail_page.dart';
import 'package:cafeplatform/provider/order_provider.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:cafeplatform/widget/network_aware_widget.dart';
import 'package:provider/provider.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    print("init state 호출");
    super.initState();
    _loadOrderList();
  }

  Future<void> _loadOrderList() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (userProvider.user != null) {
      await orderProvider.fetchOrderList(userProvider.user!.user_id);
    } else {
      print("order_list:: 로그인되지 않은 사용자");
      orderProvider.setOrderCard([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CommonAppBar(title: '주문내역'),
      body: SafeArea(
        child: NetworkAwareWidget(
          onRetry: _loadOrderList,
          child: orderList(),
        ),
      ),
    );
  }

  Widget orderList() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        List<Order> orderList = orderProvider.orderCards ?? [];

        print('orderList length: ${orderList.length}');
        if (orderList.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "구매 내역이 없습니다.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return RefreshIndicator(
            onRefresh: () async {
              await _loadOrderList();
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: orderList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: order(orderList[index]),
                );
              },
            ),
          );
        }
      },
    );
  }

  Widget order(Order order) {
    return GestureDetector(
      onTap: () {
        print("item 선택됨");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(orderId: order.order_id),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 주문일과 주문상세 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 6),
                    Text(
                      "주문일",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      order.created_time.toDateTimeStringShort,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OrderDetailPage(orderId: order.order_id),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        '주문상세',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // 상품 정보
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.menu_name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "${order.price}원",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
