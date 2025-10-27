import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_food2go/core/services/dio_helper.dart';
import 'package:admin_food2go/core/utils/error_handler.dart';
import '../model/branch_model.dart';
import '../model/dine_model.dart';
import 'dart:developer';
import 'package:admin_food2go/core/services/role_manager.dart';
import 'dine_state.dart';

class DineCubit extends Cubit<DineState> {
  DineCubit() : super(DineInitial()) {
    _initializeBasedOnRole();
  }

  static DineCubit get(context) => BlocProvider.of(context);

  // Data holders
  DineModel? dineModel;
  List<Orders>? orders;
  List<Tables>? tables;

  BranchModel? branchModel;
  List<Branches>? branches;
  Branches? selectedBranch;

  void _initializeBasedOnRole() {
    final directRole = RoleManager.getDirectRole();
    if (directRole == 'branch') {
      final branchId = RoleManager.getCurrentBranchId();
      if (branchId != null) {
        // For branch role, load only current branch
        getDineOrders(branchId: branchId.toInt());
      }
    } else {
      // For admin, load all branches
      getAllBranches();
    }
  }

  /// Fetch Dine-In Orders by Branch ID
  Future<void> getDineOrders({required int branchId}) async {
    emit(DineLoading());

    try {
      final response = await DioHelper.getData(
        url: 'admin/pos/order/pos_orders',
        query: {'branch_id': branchId},
      );

      DioHelper.printResponse(response);

      if (response.statusCode == 200 && response.data != null) {
        dineModel = DineModel.fromJson(response.data);
        orders = dineModel?.orders;
        tables = dineModel?.tables;

        emit(DineSuccess());
      } else {
        emit(DineError('Failed to load orders'));
      }
    } catch (error) {
      final errorMessage = ErrorHandler.handleError(error);
      emit(DineError(errorMessage));
    }
  }

  /// Fetch All Branches
  Future<void> getAllBranches() async {
    emit(DineLoading());

    try {
      final response = await DioHelper.getData(
        url: 'admin/order/branches',
      );

      DioHelper.printResponse(response);

      if (response.statusCode == 200 && response.data != null) {
        branchModel = BranchModel.fromJson(response.data);
        branches = branchModel?.branches;

        emit(DineSuccess());
      } else {
        emit(DineError('Failed to load branches'));
      }
    } catch (error) {
      final errorMessage = ErrorHandler.handleError(error);
      emit(DineError(errorMessage));
    }
  }

  /// Select a Branch
  void selectBranch(Branches branch) {
    selectedBranch = branch;
    emit(DineSuccess());
  }

  /// Get Orders by Table
  List<Orders> getOrdersByTable(dynamic tableId) {
    if (orders == null) return [];

    return orders!.where((order) => order.table == tableId).toList();
  }

  /// Get Orders by Status
  List<Orders> getOrdersByStatus(String status) {
    if (orders == null) return [];

    return orders!.where((order) => order.orderStatus == status).toList();
  }

  /// Get Available Tables (tables without active orders)
  List<Tables> getAvailableTables() {
    if (tables == null || orders == null) return [];

    final occupiedTableIds = orders!
        .where((order) => order.orderStatus != 'completed' && order.orderStatus != 'cancelled')
        .map((order) => order.table)
        .toSet();

    return tables!.where((table) => !occupiedTableIds.contains(table.id)).toList();
  }

  /// Fetch All Branches Orders (for "All" option) - Only for admin
  Future<void> loadAllBranchesOrders() async {
    if (RoleManager.getDirectRole() != 'admin') {
      log('⚠️ All branches orders only available for admin');
      return;
    }

    emit(DineLoading());

    try {
      if (branches == null || branches!.isEmpty) {
        await getAllBranches();
      }

      List<Orders> allOrders = [];
      List<Tables> allTables = [];

      // Loop through all branches and get their orders
      for (var branch in branches ?? []) {
        if (branch.id != null) {
          try {
            final response = await DioHelper.getData(
              url: 'admin/pos/order/pos_orders',
              query: {'branch_id': branch.id},
            );

            if (response.statusCode == 200 && response.data != null) {
              final branchData = DineModel.fromJson(response.data);
              if (branchData.orders != null) {
                allOrders.addAll(branchData.orders!);
              }
              if (branchData.tables != null) {
                allTables.addAll(branchData.tables!);
              }
            }
          } catch (e) {
            print('Error loading branch ${branch.id}: $e');
            // Continue with other branches even if one fails
          }
        }
      }

      // Create a dummy branch with id -1 for "All Branches"
      selectedBranch = Branches();
      selectedBranch!.id = -1;
      selectedBranch!.name = 'All Branches';

      orders = allOrders;
      tables = allTables;

      emit(DineSuccess());
    } catch (error) {
      final errorMessage = ErrorHandler.handleError(error);
      emit(DineError(errorMessage));
    }
  }

  double getTotalAmount() {
    if (orders == null) return 0.0;

    return orders!.fold(0.0, (sum, order) => sum + (order.amount?.toDouble() ?? 0.0));
  }

  /// Refresh Data
  Future<void> refreshData({required int branchId}) async {
    await getDineOrders(branchId: branchId);
  }

  /// Clear All Data
  void clearData() {
    dineModel = null;
    orders = null;
    tables = null;
    selectedBranch = null;
    emit(DineInitial());
  }
}