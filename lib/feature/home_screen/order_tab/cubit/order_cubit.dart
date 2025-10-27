import 'package:flutter/material.dart';
import 'package:admin_food2go/core/services/dio_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/end_point.dart';
import '../../../../core/utils/error_handler.dart';
import '../model/order_count.dart';
import '../model/order_list.dart';
import '../model/order_item_model.dart';
import '../model/invoice_model.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  OrderCubit() : super(OrderInitial());

  static OrderCubit get(context) => BlocProvider.of(context);

  OrderCount? orderList;
  OrderList? orders;
  OrderItemModel? orderItem;
  InvoiceModel? invoice;

  // Get orders count and statistics
  Future<void> getOrdersCount({
    String? start,
    String? end,
  }) async {
    if (isClosed) return;
    emit(OrderLoading());

    try {
      final response = await DioHelper.getData(
        url: EndPoint.ordersCount,
        query: {
          if (start != null) 'start': start,
          if (end != null) 'end': end,
        },
      );

      DioHelper.printResponse(response);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          orderList = OrderCount.fromJson(data);
          if (isClosed) return;
          emit(OrderSuccess());
        } else {
          if (isClosed) return;
          emit(OrderError(message: 'No data received'));
        }
      } else {
        if (isClosed) return;
        emit(OrderError(
          message: 'Failed to load orders: ${response.statusCode}',
        ));
      }
    } catch (error) {
      if (isClosed) return;
      final errorMessage = ErrorHandler.handleError(error);
      emit(OrderError(message: errorMessage));
    }
  }

  // Get orders by status
  Future<void> getOrdersByStatus({
    required String orderStatus,
    String? start,
    String? end,
  }) async {
    if (isClosed) return;
    emit(OrderListLoading());

    try {
      final response = await DioHelper.getData(
        url: EndPoint.OrderList,
        query: {
          'order_status': orderStatus,
          if (start != null) 'start': start,
          if (end != null) 'end': end,
        },
      );

      DioHelper.printResponse(response);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          orders = OrderList.fromJson(data);

          if (orders?.orders == null || orders!.orders!.isEmpty) {
            if (isClosed) return;
            emit(OrderListEmpty());
          } else {
            if (isClosed) return;
            emit(OrderListSuccess());
          }
        } else {
          if (isClosed) return;
          emit(OrderError(message: 'No data received'));
        }
      } else {
        if (isClosed) return;
        emit(OrderError(
          message: 'Failed to load orders: ${response.statusCode}',
        ));
      }
    } catch (error) {
      if (isClosed) return;
      final errorMessage = ErrorHandler.handleError(error);
      emit(OrderError(message: errorMessage));
    }
  }

  // Get order item details by order ID
  Future<void> getOrderItem({required int orderId}) async {
    if (isClosed) return;
    emit(OrderLoading());

    try {
      final response = await DioHelper.getData(
        url: '${EndPoint.OrderItem}/$orderId',
      );

      DioHelper.printResponse(response);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          orderItem = OrderItemModel.fromJson(data);
          if (isClosed) return;
          emit(OrderSuccess());
        } else {
          if (isClosed) return;
          emit(OrderError(message: 'No data received'));
        }
      } else {
        if (isClosed) return;
        emit(OrderError(
          message: 'Failed to load order details: ${response.statusCode}',
        ));
      }
    } catch (error) {
      if (isClosed) return;
      final errorMessage = ErrorHandler.handleError(error);
      emit(OrderError(message: errorMessage));
    }
  }

  // Get order invoice by order ID
  Future<void> getOrderInvoice({required int orderId}) async {
    if (isClosed) return;
    emit(OrderInvoiceLoading());

    try {
      final response = await DioHelper.getData(
        url: '${EndPoint.OrderInvoice}/$orderId',
      );

      DioHelper.printResponse(response);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          invoice = InvoiceModel.fromJson(data);
          if (isClosed) return;
          emit(OrderInvoiceSuccess());
        } else {
          if (isClosed) return;
          emit(OrderError(message: 'No invoice data received'));
        }
      } else {
        if (isClosed) return;
        emit(OrderError(
          message: 'Failed to load invoice: ${response.statusCode}',
        ));
      }
    } catch (error) {
      if (isClosed) return;
      final errorMessage = ErrorHandler.handleError(error);
      emit(OrderError(message: errorMessage));
    }
  }

  // Reset state
  void resetState() {
    if (isClosed) return;
    emit(OrderInitial());
  }

  // Clear data
  void clearData() {
    orderList = null;
    orders = null;
    orderItem = null;
    invoice = null;
    if (isClosed) return;
    emit(OrderInitial());
  }

  // Clear only order item
  void clearOrderItem() {
    orderItem = null;
  }

  // Clear only invoice
  void clearInvoice() {
    invoice = null;
  }
}