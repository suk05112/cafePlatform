import 'package:flutter/material.dart';
import 'package:cafeplatform/Extension/datetime_extension.dart';
import 'package:cafeplatform/utils/analytics_service.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/api/order_detail_response.dart';
import 'package:cafeplatform/model/gifticon.dart';
import 'package:cafeplatform/provider/order_provider.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cafeplatform/utils/kakao_share_helper.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';

class OrderDetailPage extends StatefulWidget {
  final int orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isRefunding = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView('order_detail');
  }

  Future<OrderDetailResponse> _fetchOrderDetail() async {
    try {
      await Api().setBaseClient(Api.BASE_URL);
      var response = await Api().client.getOrderDetail(widget.orderId);
      return response.order_detail;
    } catch (error) {
      rethrow;
    }
  }

  // 주문 상태를 한글로 변환
  String _getOrderStatusText(String? status) {
    if (status == null) return "정보 없음";

    switch (status.toUpperCase()) {
      case 'PENDING':
        return '대기중';
      case 'COMPLETED':
        return '결제 완료';
      case 'REFUNDED':
        return '환불 완료';
      case 'UNKNOWN':
      case 'UNKONWN': // 오타 대응
        return '알 수 없음';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: const CommonAppBar(title: '주문 상세내역'),
        body: SafeArea(
            child: FutureBuilder<OrderDetailResponse>(
          future: _fetchOrderDetail(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: ColorAssset.mainColor));
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      '주문 정보를 불러올 수 없습니다.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: Text('다시 시도'),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData) {
              return Center(
                child: Text(
                  '주문 정보가 없습니다.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            }

            final orderDetail = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    gifticonInfoList(orderDetail),
                    SizedBox(height: 16),
                    storeInfo(orderDetail),
                    SizedBox(height: 16),
                    orderInfo(orderDetail),
                    SizedBox(height: 16),
                    // status가 "REFUNDED"일 경우에만 취소/환불 정보 표시
                    if (orderDetail.status?.toUpperCase() == 'REFUNDED')
                      cancellationDetails(orderDetail),
                    if (orderDetail.status?.toUpperCase() == 'REFUNDED')
                      SizedBox(height: 16),
                    SizedBox(height: 24),
                    // 기프티콘 중 하나라도 is_receiver_linked가 false이면 선물 다시 전달하기 버튼 표시
                    if (orderDetail.gifticons
                        .any((g) => g.is_receiver_linked == false))
                      resendGiftButton(orderDetail),
                    if (orderDetail.gifticons
                        .any((g) => g.is_receiver_linked == false))
                      SizedBox(height: 16),
                    if (orderDetail.status?.toUpperCase() != 'REFUNDED')
                      cancelButton(),
                  ],
                ),
              ),
            );
          },
        ))),
        if (_isRefunding)
          const ModalBarrier(dismissible: false, color: Colors.black26),
        if (_isRefunding)
          Center(
            child: CircularProgressIndicator(
              color: ColorAssset.mainColor,
            ),
          ),
      ],
    );
  }

  Widget gifticonInfoList(OrderDetailResponse orderDetail) {
    if (orderDetail.gifticons.isEmpty || orderDetail.gifticons.isEmpty) {
      return Container(
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
        child: Text(
          '기프티콘 정보가 없습니다.',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return Container(
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
          Text(
            '주문 상품 (${orderDetail.gifticon_count ?? 0}개)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          ...orderDetail.gifticons.map((gifticon) {
            final hasImage =
                gifticon.menu_url != null && gifticon.menu_url!.isNotEmpty;
            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 메뉴 이미지가 있을 경우에만 표시
                  if (hasImage)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[100],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          gifticon.menu_url!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                  // 이미지가 있을 때와 없을 때 텍스트 정렬을 맞추기 위해 간격 추가
                  SizedBox(width: hasImage ? 16 : 0),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          gifticon.menu_name ?? '메뉴명 없음',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "${gifticon.menu_price ?? 0}원",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (gifticon.type == 2) ...[
                          SizedBox(height: 4),
                          Text(
                            '선물: ${gifticon.receiver ?? ""}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget storeInfo(OrderDetailResponse orderDetail) {
    return Container(
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
          Text(
            "매장 정보",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          _buildInfoRow("매장명", orderDetail.store_name ?? "정보 없음"),
          SizedBox(height: 12),
          _buildInfoRow("주소", orderDetail.store_address ?? "정보 없음"),
          SizedBox(height: 12),
          _buildInfoRow("전화번호", orderDetail.store_telephone ?? "정보 없음"),
        ],
      ),
    );
  }

  Widget orderInfo(OrderDetailResponse orderDetail) {
    return Container(
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
          Text(
            "결제 정보",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          _buildInfoRow(
            "주문일",
            orderDetail.created_at != null
                ? orderDetail.created_at!.toDateTimeString
                : "정보 없음",
          ),
          SizedBox(height: 12),
          _buildInfoRow("주문번호", orderDetail.order_no ?? "정보 없음"),
          SizedBox(height: 12),
          _buildInfoRow("결제방식", orderDetail.payment ?? "정보 없음"),
          SizedBox(height: 12),
          _buildInfoRow(
            "결제상태",
            _getOrderStatusText(orderDetail.status),
            valueColor: orderDetail.status?.toUpperCase() == 'REFUNDED'
                ? Colors.red[700]
                : null,
          ),
          Divider(
            thickness: 1,
            height: 24,
            color: Colors.grey[200],
          ),
          Row(
            children: [
              Text(
                "총 결제금액",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Spacer(),
              Text(
                "${orderDetail.amount ?? 0}원",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget resendGiftButton(OrderDetailResponse orderDetail) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          foregroundColor: Colors.white,
          backgroundColor: ColorAssset.mainColor,
          elevation: 0,
        ),
        onPressed: () {
          _shareGifticonToKakao(orderDetail);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.share, size: 20),
            SizedBox(width: 8),
            Text(
              '선물 다시 전달하기',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareGifticonToKakao(OrderDetailResponse orderDetail) async {
    if (orderDetail.gifticons.isEmpty) {
      _showToast('공유할 기프티콘이 없습니다.');
      return;
    }

    // 첫 번째 기프티콘을 사용하여 공유
    final gifticonData = orderDetail.gifticons.first;

    // Gifticon 객체 생성
    final gifticon = Gifticon(
      gifticon_id: gifticonData.gifticon_id ?? 0,
      order_id: orderDetail.order_id ?? 0,
      name: gifticonData.menu_name ?? '',
      sender: gifticonData.sender ?? '',
      receiver: gifticonData.receiver ?? '',
      receiver_phone_number: gifticonData.receiver_phone,
      store_name: orderDetail.store_name ?? '',
      menu_url: gifticonData.menu_url,
      total_price: gifticonData.menu_price ?? 0,
      description: '',
      validity: gifticonData.validity,
      status: gifticonData.status,
      type: gifticonData.type,
      store_id: orderDetail.store_id,
      store_lat: 0.0,
      store_lng: 0.0,
    );

    try {
      await KakaoShareHelper.shareGifticon(
        gifticon,
        onSuccess: () {
          _showToast('카카오톡으로 선물을 전달했습니다.');
        },
        onError: (error) {
          _showToast('카카오톡 공유에 실패했습니다.');
        },
      );
    } catch (error) {
      _showToast('카카오톡 공유 중 오류가 발생했습니다.');
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  Widget cancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          foregroundColor: Colors.black87,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        onPressed: () {
          _showCancelConfirmDialog();
        },
        child: Text(
          '구매 취소',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showCancelConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.zero,
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 상단 아이콘 영역
                Container(
                  padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          size: 40,
                          color: Colors.orange[700],
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "주문을 취소하시겠습니까?",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Colors.grey[700],
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "취소 시 교환권을 더이상 사용하실 수 없으며, 선물 상품인 경우, 선물을 받으신 분께 선물 취소 메시지가 발송됩니다.",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[800],
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 하단 버튼 영역
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                              ),
                            ),
                          ),
                          child: Text(
                            '취소',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 56,
                        color: Colors.grey[200],
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            _handleRefund();
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                          ),
                          child: Text(
                            '확인',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleRefund() async {
    setState(() => _isRefunding = true);
    try {
      // 환불 API 호출
      await Api().client.refundGifticon(widget.orderId);

      // 성공 메시지
      Fluttertoast.showToast(
        msg: "환불이 완료되었습니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );

      // 주문내역 다시 불러오기
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      if (userProvider.user != null) {
        await orderProvider.fetchOrderList(userProvider.user!.user_id);
      }

      // 이전 페이지(주문내역 페이지)로 돌아가기
      if (mounted) {
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      String errorMessage = "환불 처리 중 오류가 발생했습니다.";

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        if (statusCode == 404) {
          errorMessage = "주문을 찾을 수 없습니다.";
        } else if (statusCode == 400) {
          errorMessage = "이미 취소된 주문이거나 환불할 수 없는 주문입니다.";
        } else if (statusCode == 500) {
          errorMessage = "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.";
        }
      } else {
        errorMessage = "네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요.";
      }

      if (mounted) {
        _showRefundFailureDialog(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        _showRefundFailureDialog("예기치 않은 오류가 발생했습니다.");
      }
    } finally {
      if (mounted) setState(() => _isRefunding = false);
    }
  }

  void _showRefundFailureDialog(String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.zero,
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 상단 아이콘 영역
                Container(
                  padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline_rounded,
                          size: 40,
                          color: Colors.red[700],
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "환불 실패",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.grey[700],
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[800],
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 하단 버튼 영역
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                      ),
                      child: Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget cancellationDetails(OrderDetailResponse orderDetail) {
    return Container(
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
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          '취소/환불 정보',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        initiallyExpanded: false,
        children: <Widget>[
          Column(
            children: [
              _buildInfoRow("결제 상태", _getOrderStatusText(orderDetail.status)),
              SizedBox(height: 12),
              _buildInfoRow("총 취소금액", "${orderDetail.amount ?? 0}원"),
            ],
          ),
        ],
      ),
    );
  }
}
