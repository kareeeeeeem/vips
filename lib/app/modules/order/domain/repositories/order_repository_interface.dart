import 'package:vip/app/core/common/models/response_model.dart';
import 'package:vip/app/modules/order/domain/models/order_model.dart';

import '../../../../core/api/api_client.dart';
import '../models/update_status_body_model.dart';

abstract class OrderRepositoryInterface {
  Future<dynamic> getPaginatedOrderList(int offset, String status);
  Future<dynamic> updateOrderStatus(
    UpdateStatusBodyModel updateStatusBody,
    List<MultipartBody> proofAttachment,
  );
  Future<dynamic> getOrderDetails(int orderID);
  Future<dynamic> getCancelReasons();
  Future<dynamic> sendDeliveredNotification(int? orderID);
  Future<void> setBluetoothAddress(String? address);
  String? getBluetoothAddress();

  Future<List<OrderModel>?> getList();
  Future<OrderModel?> get(int? id);

  Future<ResponseModel> update(Map<String, String> body);
}
