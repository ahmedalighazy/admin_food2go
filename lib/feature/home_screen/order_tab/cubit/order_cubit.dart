import 'package:dio/dio.dart';
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

  // ── Get orders count (للـ OrderTab) ──────────────────────────────────────
  Future<void> getOrdersCount({String? start, String? end}) async {
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
      if (response.statusCode == 200 && response.data != null) {
        orderList = OrderCount.fromJson(response.data);
        if (isClosed) return;
        emit(OrderSuccess());
      } else {
        if (isClosed) return;
        emit(OrderError(message: 'Failed to load orders: ${response.statusCode}'));
      }
    } catch (error) {
      if (isClosed) return;
      emit(OrderError(message: ErrorHandler.handleError(error)));
    }
  }

  // ── Get orders count بدون ما يأثر على الـ UI (للـ OrderListScreen) ────────
  Future<void> refreshOrdersCount({String? start, String? end}) async {
    if (isClosed) return;
    emit(OrderCountLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.ordersCount,
        query: {
          if (start != null) 'start': start,
          if (end != null) 'end': end,
        },
      );
      DioHelper.printResponse(response);
      if (response.statusCode == 200 && response.data != null) {
        orderList = OrderCount.fromJson(response.data);
        if (isClosed) return;
        emit(OrderCountSuccess());
      } else {
        if (isClosed) return;
        emit(OrderCountError(message: 'Failed: ${response.statusCode}'));
      }
    } catch (error) {
      if (isClosed) return;
      emit(OrderCountError(message: ErrorHandler.handleError(error)));
    }
  }

  // ── Get orders by status ──────────────────────────────────────────────────
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
      if (response.statusCode == 200 && response.data != null) {
        orders = OrderList.fromJson(response.data);
        if (isClosed) return;
        if (orders?.orders == null || orders!.orders!.isEmpty) {
          emit(OrderListEmpty());
        } else {
          emit(OrderListSuccess());
        }
      } else {
        if (isClosed) return;
        emit(OrderListError(message: 'Failed: ${response.statusCode}'));
      }
    } catch (error) {
      if (isClosed) return;
      emit(OrderListError(message: ErrorHandler.handleError(error)));
    }
  }

  // ── Get order item ────────────────────────────────────────────────────────
  Future<void> getOrderItem({required int orderId}) async {
    if (isClosed) return;
    emit(OrderItemLoading());
    try {
      print('🔍 Fetching order item for orderId: $orderId');
      final response = await DioHelper.getData(
        url: '${EndPoint.OrderItem}/$orderId',
      );
      DioHelper.printResponse(response);
      
      print('📦 Response status: ${response.statusCode}');
      print('📦 Response data type: ${response.data.runtimeType}');
      print('📦 Response data: ${response.data}');
      
      if (response.statusCode == 200 && response.data != null) {
        try {
          print('🔄 Starting to parse order item...');
          orderItem = OrderItemModel.fromJson(response.data);
          print('✅ Order item parsed successfully');
          if (isClosed) return;
          emit(OrderItemSuccess());
        } catch (parseError, stackTrace) {
          print('❌ Parsing error: $parseError');
          print('📍 Stack trace: $stackTrace');
          if (isClosed) return;
          emit(OrderItemError(message: 'Failed to parse order data: $parseError'));
        }
      } else {
        if (isClosed) return;
        emit(OrderItemError(message: 'Failed: ${response.statusCode}'));
      }
    } catch (error) {
      print('❌ Error in getOrderItem: $error');
      if (isClosed) return;
      emit(OrderItemError(message: ErrorHandler.handleError(error)));
    }
  }

  // ── Get order invoice ─────────────────────────────────────────────────────
  Future<void> getOrderInvoice({required int orderId}) async {
    if (isClosed) return;
    emit(OrderInvoiceLoading());
    try {
      final response = await DioHelper.getData(
        url: '${EndPoint.OrderInvoice}/$orderId',
      );
      DioHelper.printResponse(response);
      if (response.statusCode == 200 && response.data != null) {
        print('🔍 Parsing invoice data...');
        print('🔍 Response data type: ${response.data.runtimeType}');
        print('🔍 Response data keys: ${response.data is Map ? response.data.keys.toList() : 'Not a map'}');
        
        invoice = InvoiceModel.fromJson(response.data);
        
        print('✅ Invoice parsed successfully');
        print('✅ Invoice.order is null: ${invoice?.order == null}');
        if (invoice?.order != null) {
          print('✅ Order ID: ${invoice!.order!.id}');
          print('✅ Order Number: ${invoice!.order!.orderNumber}');
        }
        
        if (isClosed) return;
        emit(OrderInvoiceSuccess());
      } else {
        if (isClosed) return;
        emit(OrderInvoiceError(message: 'Failed: ${response.statusCode}'));
      }
    } catch (error, stackTrace) {
      print('❌ Error parsing invoice: $error');
      print('❌ Stack trace: $stackTrace');
      if (isClosed) return;
      emit(OrderInvoiceError(message: ErrorHandler.handleError(error)));
    }
  }

  // ── Change order status ───────────────────────────────────────────────────
  Future<void> changeOrderStatus({
    required int orderId,
    required String newStatus,
  }) async {
    if (isClosed) return;
    emit(OrderStatusChangeLoading());
    try {
      final response = await DioHelper.putData(
        url: '${EndPoint.ordersChangeStatus}$orderId',
        data: {'order_status': newStatus},
      );
      DioHelper.printResponse(response);
      if (response.statusCode == 200) {
        if (isClosed) return;
        emit(OrderStatusChangeSuccess());
        if (orders?.orders != null) {
          final idx = orders!.orders!.indexWhere((o) => o.id == orderId);
          if (idx != -1) orders!.orders![idx].orderStatus = newStatus;
        }
      } else {
        if (isClosed) return;
        emit(OrderStatusChangeError(message: 'Failed: ${response.statusCode}'));
      }
    } catch (error) {
      if (isClosed) return;
      emit(OrderStatusChangeError(message: ErrorHandler.handleError(error)));
    }
  }

  void resetState() {
    if (isClosed) return;
    emit(OrderInitial());
  }

  void clearData() {
    orderList = null;
    orders = null;
    orderItem = null;
    invoice = null;
    if (isClosed) return;
    emit(OrderInitial());
  }

  void clearOrderItem() => orderItem = null;
  void clearInvoice() => invoice = null;
}