import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_ui.dart';
import '../cubit/dine_cubit.dart';
import '../cubit/dine_state.dart';
import '../model/dine_model.dart';
import 'package:admin_food2go/core/services/role_manager.dart';

class DineInOrderTab extends StatefulWidget {
  const DineInOrderTab({super.key});

  @override
  State<DineInOrderTab> createState() => _DineInOrderTabState();
}

class _DineInOrderTabState extends State<DineInOrderTab> with SingleTickerProviderStateMixin {
  String selectedFilter = 'All';
  String searchQuery = ''; // Search query variable
  late TabController _tabController;
  late TextEditingController _searchController; // Search controller
  final directRole = RoleManager.getDirectRole();
  bool isBranchRole = false;
  num? currentBranchId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController = TextEditingController(); // Initialize search controller
    isBranchRole = directRole == 'branch';
    if (isBranchRole) {
      currentBranchId = RoleManager.getCurrentBranchId();
      // Directly load branch-specific data instead of all branches
      DineCubit.get(context).getDineOrders(branchId: currentBranchId!.toInt());
    } else {
      // Only load branches for non-branch roles
      DineCubit.get(context).getAllBranches();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose(); // Dispose search controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DineCubit, DineState>(
      listener: (context, state) {
        if (state is DineError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: ResponsiveUI.spacing(context, 12)),
                  Expanded(
                    child: Text(
                      state.message,
                      style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14)),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.fixed, // Changed from floating to fixed
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ResponsiveUI.borderRadius(context, 12)),
                  topRight: Radius.circular(ResponsiveUI.borderRadius(context, 12)),
                ),
              ),
              // Removed: margin: EdgeInsets.zero, // FIXED: Unsupported with fixed behavior
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = DineCubit.get(context);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey.shade50,
                Colors.white,
              ],
            ),
          ),
          child: Column(
            children: [
              // Branch Selector - Fixed at top (no scroll)
              _buildBranchSelector(cubit, state),

              // Rest of content - Scrollable
              if (cubit.selectedBranch != null || isBranchRole)
                Expanded(
                  child: SingleChildScrollView(  // إضافة: لجعل كل المحتوى scrollable
                    physics: const BouncingScrollPhysics(),  // تأثير scroll ناعم
                    padding: EdgeInsets.only(bottom: ResponsiveUI.padding(context, 20)),  // padding أسفل للـ scroll
                    child: Column(
                      children: [
                        SizedBox(height: ResponsiveUI.spacing(context, 16)),
                        _buildTabBar(),
                        SizedBox(height: ResponsiveUI.spacing(context, 16)),
                        _buildStatisticsCards(cubit),
                        SizedBox(height: ResponsiveUI.spacing(context, 20)),
                        SizedBox(  // إضافة: container بارتفاع responsive للـ TabBarView
                          height: MediaQuery.of(context).size.height * 0.6,  // 60% من ارتفاع الشاشة للـ tabs
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildTablesTab(cubit, state),
                              _buildOrdersTab(cubit, state),
                              _buildCaptainOrdersTab(cubit, state),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBranchSelector(DineCubit cubit, DineState state) {
    if (isBranchRole) {
      // For branch role, show fixed branch info
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppColors.colorPrimaryLight.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
          boxShadow: [
            BoxShadow(
              color: AppColors.colorPrimary.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                    decoration: BoxDecoration(
                      color: AppColors.colorPrimary,
                      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.colorPrimary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.store_rounded,
                      color: Colors.white,
                      size: ResponsiveUI.iconSize(context, 24),
                    ),
                  ),
                  SizedBox(width: ResponsiveUI.spacing(context, 12)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Branch',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 20),
                          fontWeight: FontWeight.bold,
                          color: AppColors.colorPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Managing your branch location',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 12),
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 16)),
              Container(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                  border: Border.all(color: Colors.grey.shade200, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: ResponsiveUI.iconSize(context, 18),
                      color: AppColors.colorPrimary,
                    ),
                    SizedBox(width: ResponsiveUI.spacing(context, 12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Branch ID: $currentBranchId',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.colorPrimary,
                              fontSize: ResponsiveUI.fontSize(context, 15),
                            ),
                          ),
                          Text(
                            'Your assigned branch',
                            style: TextStyle(
                              fontSize: ResponsiveUI.fontSize(context, 12),
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is DineLoading && cubit.branches == null) {
      return Container(
        margin: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 24)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
          ),
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
          boxShadow: [
            BoxShadow(
              color: AppColors.colorPrimary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.colorPrimaryLight.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorPrimary.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                  decoration: BoxDecoration(
                    color: AppColors.colorPrimary,
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.colorPrimary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.store_rounded,
                    color: Colors.white,
                    size: ResponsiveUI.iconSize(context, 24),
                  ),
                ),
                SizedBox(width: ResponsiveUI.spacing(context, 12)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Branch',
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 20),
                        fontWeight: FontWeight.bold,
                        color: AppColors.colorPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Choose your working location',
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 12),
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 16)),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonFormField<int>(
                value: cubit.selectedBranch?.id?.toInt(),
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.colorPrimary,
                  size: ResponsiveUI.iconSize(context, 28),
                ),
                decoration: InputDecoration(
                  hintText: 'Choose a branch',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: ResponsiveUI.fontSize(context, 15),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUI.padding(context, 16),
                    vertical: ResponsiveUI.padding(context, 16),
                  ),
                ),
                dropdownColor: Colors.white,
                items: [
                  DropdownMenuItem<int>(
                    value: -1,
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(ResponsiveUI.padding(context, 8)),
                          decoration: BoxDecoration(
                            color: AppColors.colorPrimaryLight,
                            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                          ),
                          child: Icon(
                            Icons.grid_view_rounded,
                            size: ResponsiveUI.iconSize(context, 18),
                            color: AppColors.colorPrimary,
                          ),
                        ),
                        SizedBox(width: ResponsiveUI.spacing(context, 12)),
                        Text(
                          'All Branches',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.colorPrimary,
                            fontSize: ResponsiveUI.fontSize(context, 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...?cubit.branches?.map((branch) {
                    return DropdownMenuItem<int>(
                      value: branch.id?.toInt(),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(ResponsiveUI.padding(context, 8)),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              size: ResponsiveUI.iconSize(context, 18),
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(width: ResponsiveUI.spacing(context, 12)),
                          Expanded(
                            child: Text(
                              branch.name ?? 'Unknown Branch',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 15),
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
                onChanged: (branchId) async {
                  if (branchId == -1) {
                    await cubit.loadAllBranchesOrders();
                  } else if (branchId != null) {
                    final branch = cubit.branches?.firstWhere((b) => b.id == branchId);
                    if (branch != null) {
                      cubit.selectBranch(branch);
                      await cubit.getDineOrders(branchId: branchId);
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 16)),
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 4)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.colorPrimary, AppColors.colorPrimaryDark],
          ),
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
          boxShadow: [
            BoxShadow(
              color: AppColors.colorPrimary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: ResponsiveUI.fontSize(context, 13),
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: ResponsiveUI.fontSize(context, 13),
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            icon: Icon(Icons.table_restaurant_rounded, size: ResponsiveUI.iconSize(context, 22)),
            text: 'Tables',
            height: ResponsiveUI.value(context, 60),
          ),
          Tab(
            icon: Icon(Icons.receipt_long_rounded, size: ResponsiveUI.iconSize(context, 22)),
            text: 'Orders',
            height: ResponsiveUI.value(context, 60),
          ),
          Tab(
            icon: Icon(Icons.people_rounded, size: ResponsiveUI.iconSize(context, 22)),
            text: 'Captains',
            height: ResponsiveUI.value(context, 60),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(DineCubit cubit) {
    final totalOrders = cubit.orders?.length ?? 0;
    final totalTables = cubit.tables?.length ?? 0;
    final availableTables = cubit.getAvailableTables().length;
    final totalAmount = cubit.getTotalAmount();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 8)),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.receipt_long_rounded,
              title: 'Orders',
              value: totalOrders.toString(),
              gradient: const LinearGradient(
                colors: [Color(0xFF6B46C1), Color(0xFF9F7AEA)],
              ),
            ),
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 12)),
          Expanded(
            child: _buildStatCard(
              icon: Icons.table_restaurant_rounded,
              title: 'Available',
              value: '$availableTables/$totalTables',
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.green.shade400],
              ),
            ),
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 12)),
          Expanded(
            child: _buildStatCard(
              icon: Icons.payments_rounded,
              title: 'Revenue',
              value: '${totalAmount.toStringAsFixed(0)}',
              valueSubtext: 'EGP',
              gradient: LinearGradient(
                colors: [Colors.orange.shade600, Colors.orange.shade400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    String? valueSubtext,
    required Gradient gradient,
  }) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 10)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
            ),
            child: Icon(icon, color: Colors.white, size: ResponsiveUI.iconSize(context, 28)),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 22),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (valueSubtext != null) ...[
                SizedBox(width: ResponsiveUI.spacing(context, 4)),
                Padding(
                  padding: EdgeInsets.only(bottom: ResponsiveUI.padding(context, 2)),
                  child: Text(
                    valueSubtext,
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 11),
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 4)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 12),
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTablesTab(DineCubit cubit, DineState state) {
    if (state is DineLoading && cubit.tables == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final tables = cubit.tables ?? [];
    final availableTables = cubit.getAvailableTables();

    if (tables.isEmpty) {
      return _buildEmptyState(
        icon: Icons.table_restaurant_rounded,
        title: 'No Tables Found',
        message: isBranchRole
            ? 'There are no tables available for your branch'
            : 'There are no tables available for this branch',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Add a simple debounce to prevent spam calls
        await Future.delayed(const Duration(milliseconds: 300));
        if (isBranchRole) {
          await cubit.refreshData(branchId: currentBranchId!.toInt());
        } else if (cubit.selectedBranch?.id == -1) {
          await cubit.loadAllBranchesOrders();
        } else {
          await cubit.refreshData(branchId: cubit.selectedBranch?.id?.toInt() ?? 0);
        }
      },
      child: ListView.builder(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
        itemCount: tables.length,
        itemBuilder: (context, index) {
          final table = tables[index];
          final isAvailable = availableTables.contains(table);
          final tableOrders = cubit.getOrdersByTable(table.id);

          return _buildTableCard(table, isAvailable, tableOrders);
        },
      ),
    );
  }

  Widget _buildTableCard(Tables table, bool isAvailable, List tableOrders) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 12)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isAvailable
              ? [Colors.white, Colors.green.shade50.withOpacity(0.3)]
              : [Colors.white, AppColors.colorPrimaryLight.withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
        border: Border.all(
          color: isAvailable
              ? Colors.green.shade300.withOpacity(0.5)
              : AppColors.colorPrimary.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isAvailable ? Colors.green : AppColors.colorPrimary).withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 14)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isAvailable
                          ? [Colors.green.shade400, Colors.green.shade600]
                          : [AppColors.colorPrimary, AppColors.colorPrimaryDark],
                    ),
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
                    boxShadow: [
                      BoxShadow(
                        color: (isAvailable ? Colors.green : AppColors.colorPrimary).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.table_restaurant_rounded,
                    color: Colors.white,
                    size: ResponsiveUI.iconSize(context, 32),
                  ),
                ),
                SizedBox(width: ResponsiveUI.spacing(context, 16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Table ${table.tableNumber ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 20),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 4)),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: ResponsiveUI.iconSize(context, 14),
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(width: ResponsiveUI.spacing(context, 4)),
                          Text(
                            table.location ?? 'No location',
                            style: TextStyle(
                              fontSize: ResponsiveUI.fontSize(context, 13),
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUI.padding(context, 14),
                    vertical: ResponsiveUI.padding(context, 8),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isAvailable
                          ? [Colors.green.shade50, Colors.green.shade100]
                          : [AppColors.colorPrimaryLight, AppColors.colorPrimaryLight.withOpacity(0.5)],
                    ),
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                    border: Border.all(
                      color: isAvailable ? Colors.green.shade300 : AppColors.colorPrimary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: ResponsiveUI.value(context, 8),
                        height: ResponsiveUI.value(context, 8),
                        decoration: BoxDecoration(
                          color: isAvailable ? Colors.green.shade600 : AppColors.colorPrimary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isAvailable ? Colors.green : AppColors.colorPrimary).withOpacity(0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: ResponsiveUI.spacing(context, 8)),
                      Text(
                        isAvailable ? 'Available' : 'Occupied',
                        style: TextStyle(
                          color: isAvailable ? Colors.green.shade700 : AppColors.colorPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveUI.fontSize(context, 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 16)),
            Container(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 14)),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTableInfo(
                      Icons.chair_rounded,
                      'Capacity',
                      table.capacity?.toString() ?? 'N/A',
                      Colors.blue.shade600,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: ResponsiveUI.value(context, 40),
                    color: Colors.grey.shade300,
                  ),
                  Expanded(
                    child: _buildTableInfo(
                      Icons.receipt_rounded,
                      'Orders',
                      tableOrders.length.toString(),
                      Colors.orange.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (table.isMerge == 1) ...[
              SizedBox(height: ResponsiveUI.spacing(context, 12)),
              Container(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.colorPrimaryLight, AppColors.colorPrimaryLight.withOpacity(0.5)],
                  ),
                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                  border: Border.all(color: AppColors.colorPrimary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.merge_type_rounded,
                      size: ResponsiveUI.iconSize(context, 18),
                      color: AppColors.colorPrimary,
                    ),
                    SizedBox(width: ResponsiveUI.spacing(context, 8)),
                    Text(
                      'Merged Table',
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 13),
                        color: AppColors.colorPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTableInfo(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, size: ResponsiveUI.iconSize(context, 22), color: color),
        SizedBox(height: ResponsiveUI.spacing(context, 6)),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 18),
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 2)),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 11),
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // Modified: _buildOrdersTab with Search Bar
  Widget _buildOrdersTab(DineCubit cubit, DineState state) {
    return Column(
      children: [
        _buildSearchBar(), // Added: New Search Bar
        SizedBox(height: ResponsiveUI.spacing(context, 12)),
        _buildFilterTabs(),
        SizedBox(height: ResponsiveUI.spacing(context, 16)),
        Expanded(child: _buildOrdersList(cubit, state)),
      ],
    );
  }

  // Added: Search Bar Widget
  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase(); // Update search query
          });
        },
        decoration: InputDecoration(
          hintText: 'Search by order number...', // Changed to English
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: ResponsiveUI.fontSize(context, 14),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.colorPrimary,
            size: ResponsiveUI.iconSize(context, 22),
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(
              Icons.clear_rounded,
              color: Colors.grey.shade500,
              size: ResponsiveUI.iconSize(context, 20),
            ),
            onPressed: () {
              _searchController.clear();
              setState(() {
                searchQuery = '';
              });
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
            borderSide: BorderSide(color: AppColors.colorPrimary, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveUI.padding(context, 16),
            vertical: ResponsiveUI.padding(context, 16),
          ),
          fillColor: Colors.white,
          filled: true,
        ),
        style: TextStyle(
          fontSize: ResponsiveUI.fontSize(context, 14),
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = ['All', 'Pending', 'Confirmed', 'Processing', 'Completed'];

    return Container(
      height: ResponsiveUI.value(context, 50),
      margin: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 16)),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return Padding(
            padding: EdgeInsets.only(right: ResponsiveUI.spacing(context, 8)),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) => setState(() => selectedFilter = filter),
              backgroundColor: Colors.white,
              selectedColor: AppColors.colorPrimary,
              side: BorderSide(
                color: isSelected ? AppColors.colorPrimary : Colors.grey.shade300,
                width: 1.5,
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: ResponsiveUI.fontSize(context, 13),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.padding(context, 12),
                vertical: ResponsiveUI.padding(context, 8),
              ),
              elevation: isSelected ? 4 : 0,
              shadowColor: AppColors.colorPrimary.withOpacity(0.3),
            ),
          );
        },
      ),
    );
  }

  // Modified: _buildOrdersList with search filtering
  Widget _buildOrdersList(DineCubit cubit, DineState state) {
    if (state is DineLoading && cubit.orders == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Filter by Status first
    List<Orders> statusFilteredOrders = selectedFilter == 'All'
        ? cubit.orders ?? []
        : cubit.getOrdersByStatus(selectedFilter.toLowerCase());

    // Added: Filter by search (on orderNumber)
    List<Orders> filteredOrders = statusFilteredOrders.where((order) {
      if (searchQuery.isEmpty) return true;
      final orderNumber = order.orderNumber?.toLowerCase() ?? '';
      return orderNumber.contains(searchQuery);
    }).toList();

    if (filteredOrders.isEmpty) {
      return _buildEmptyState(
        icon: searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.inbox_rounded,
        title: searchQuery.isNotEmpty ? 'No Results Found' : 'No Orders Found', // Changed to English
        message: searchQuery.isNotEmpty
            ? 'No orders match the search: "$searchQuery"' // Changed to English
            : isBranchRole
            ? 'No orders found for your branch with the selected filters'
            : cubit.selectedBranch?.id == -1
            ? 'No orders found across all branches'
            : 'There are no orders for the selected filters',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Add a simple debounce to prevent spam calls
        await Future.delayed(const Duration(milliseconds: 300));
        if (isBranchRole) {
          await cubit.refreshData(branchId: currentBranchId!.toInt());
        } else if (cubit.selectedBranch?.id == -1) {
          await cubit.loadAllBranchesOrders();
        } else {
          await cubit.refreshData(branchId: cubit.selectedBranch?.id?.toInt() ?? 0);
        }
      },
      child: ListView.builder(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) => _buildOrderCard(filteredOrders[index], cubit),
      ),
    );
  }

  Widget _buildOrderCard(order, DineCubit cubit) {
    final statusColor = _getStatusColor(order.orderStatus ?? '');
    Tables? table;
    try {
      table = cubit.tables?.firstWhere((t) => t.id == order.table);
    } catch (e) {
      table = null;
    }

    String branchName = '';
    if (!isBranchRole && cubit.selectedBranch?.id == -1) {
      try {
        final branch = cubit.branches?.firstWhere((b) => b.id == order.branchId);
        branchName = branch?.name ?? '';
      } catch (e) {
        branchName = '';
      }
    } else if (isBranchRole) {
      branchName = 'Your Branch';
    }

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 14)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, statusColor.withOpacity(0.03)],
        ),
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: ResponsiveUI.spacing(context, 8),
                    runSpacing: ResponsiveUI.spacing(context, 8),
                    children: [
                      _buildStatusBadge(order.orderStatus?.toUpperCase() ?? 'UNKNOWN', statusColor),
                      _buildTypeBadge(order.type?.toUpperCase() ?? 'DINE-IN'),
                      if (branchName.isNotEmpty && !isBranchRole) _buildBranchBadge(branchName),
                      if (isBranchRole) _buildBranchBadge(branchName),
                    ],
                  ),
                ),
                SizedBox(width: ResponsiveUI.spacing(context, 8)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUI.padding(context, 12),
                    vertical: ResponsiveUI.padding(context, 6),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.colorPrimary,
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.colorPrimary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    '#${order.orderNumber ?? 'N/A'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUI.fontSize(context, 15),
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 16)),
            Container(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 8)),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildOrderInfoItem(
                          Icons.table_restaurant_rounded,
                          'Table',
                          table?.tableNumber ?? order.table?.toString() ?? 'N/A', // FIXED: Fallback to raw table ID
                          Colors.blue.shade600,
                        ),
                      ),
                      Container(width: 1, height: ResponsiveUI.value(context, 25), color: Colors.grey.shade300),
                      Expanded(
                        child: _buildOrderInfoItem(
                          Icons.person_rounded,
                          'Captain',
                          order.captain?.toString() ?? 'N/A',
                          Colors.purple.shade600,
                        ),
                      ),
                    ],
                  ),
                  if (table?.capacity != null || table?.location != null) ...[
                    SizedBox(height: ResponsiveUI.spacing(context, 6)),
                    Divider(color: Colors.grey.shade300, height: 1),
                    SizedBox(height: ResponsiveUI.spacing(context, 6)),
                    Row(
                      children: [
                        if (table?.capacity != null)
                          Expanded(
                            child: _buildOrderInfoItem(
                              Icons.chair_rounded,
                              'Capacity',
                              table!.capacity.toString(),
                              Colors.orange.shade600,
                            ),
                          ),
                        if (table?.capacity != null && table?.location != null)
                          Container(width: 1, height: ResponsiveUI.value(context, 25), color: Colors.grey.shade300),
                        if (table?.location != null)
                          Expanded(
                            child: _buildOrderInfoItem(
                              Icons.location_on_rounded,
                              'Location',
                              table!.location!,
                              Colors.green.shade600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 16)),
            Container(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.colorPrimary.withOpacity(0.05), AppColors.colorPrimaryLight.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                border: Border.all(color: AppColors.colorPrimary.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: ResponsiveUI.fontSize(context, 12),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 4)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${order.amount ?? 0}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveUI.fontSize(context, 26),
                              color: AppColors.colorPrimary,
                            ),
                          ),
                          SizedBox(width: ResponsiveUI.spacing(context, 4)),
                          Padding(
                            padding: EdgeInsets.only(bottom: ResponsiveUI.padding(context, 3)),
                            child: Text(
                              'EGP',
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 14),
                                fontWeight: FontWeight.w600,
                                color: AppColors.colorPrimary.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildAmountDetail('Tax', order.totalTax ?? 0),
                      SizedBox(height: ResponsiveUI.spacing(context, 6)),
                      _buildAmountDetail('Discount', order.totalDiscount ?? 0),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 12),
        vertical: ResponsiveUI.padding(context, 6),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: ResponsiveUI.value(context, 6),
            height: ResponsiveUI.value(context, 6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 6)),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUI.fontSize(context, 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 10),
        vertical: ResponsiveUI.padding(context, 5),
      ),
      decoration: BoxDecoration(
        color: AppColors.colorPrimaryLight,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 6)),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: AppColors.colorPrimary,
          fontSize: ResponsiveUI.fontSize(context, 10),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBranchBadge(String branchName) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 10),
        vertical: ResponsiveUI.padding(context, 5),
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 6)),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.store_rounded, size: ResponsiveUI.iconSize(context, 12), color: Colors.blue.shade700),
          SizedBox(width: ResponsiveUI.spacing(context, 4)),
          Text(
            branchName,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: ResponsiveUI.fontSize(context, 10),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoItem(IconData icon, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: ResponsiveUI.iconSize(context, 18), color: color),
        SizedBox(width: ResponsiveUI.spacing(context, 8)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 10),
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 13),
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountDetail(String label, num amount) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 12),
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '$amount EGP',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 12),
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildCaptainOrdersTab(DineCubit cubit, DineState state) {
    if (state is DineLoading && cubit.orders == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final orders = cubit.orders ?? [];
    final ordersWithCaptain = orders.where((o) => o.captain != null).toList();

    final Map<dynamic, List<Orders>> ordersByCaptain = {};
    for (var order in ordersWithCaptain) {
      if (!ordersByCaptain.containsKey(order.captain)) {
        ordersByCaptain[order.captain] = [];
      }
      ordersByCaptain[order.captain]!.add(order);
    }

    if (ordersByCaptain.isEmpty) {
      return _buildEmptyState(
        icon: Icons.person_pin_outlined,
        title: 'No Captain Orders',
        message: isBranchRole
            ? 'There are no orders assigned to captains in your branch yet'
            : 'There are no orders assigned to captains yet',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Add a simple debounce to prevent spam calls
        await Future.delayed(const Duration(milliseconds: 300));
        if (isBranchRole) {
          await cubit.refreshData(branchId: currentBranchId!.toInt());
        } else if (cubit.selectedBranch?.id == -1) {
          await cubit.loadAllBranchesOrders();
        } else {
          await cubit.refreshData(branchId: cubit.selectedBranch?.id?.toInt() ?? 0);
        }
      },
      child: ListView.builder(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
        itemCount: ordersByCaptain.length,
        itemBuilder: (context, index) {
          final captain = ordersByCaptain.keys.elementAt(index);
          final captainOrders = ordersByCaptain[captain]!;
          final totalAmount = captainOrders.fold<double>(0, (sum, order) => sum + (order.amount?.toDouble() ?? 0));

          return _buildCaptainCard(captain, captainOrders, totalAmount);
        },
      ),
    );
  }

  Widget _buildCaptainCard(dynamic captain, List<Orders> captainOrders, double totalAmount) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 14)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.purple.shade50.withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
        border: Border.all(color: Colors.purple.shade200.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.all(ResponsiveUI.padding(context, 18)),
          childrenPadding: EdgeInsets.only(
            left: ResponsiveUI.padding(context, 18),
            right: ResponsiveUI.padding(context, 18),
            bottom: ResponsiveUI.padding(context, 18),
          ),
          leading: Container(
            width: ResponsiveUI.value(context, 56),
            height: ResponsiveUI.value(context, 56),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.purple.shade600],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                captain.toString().substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUI.fontSize(context, 22),
                ),
              ),
            ),
          ),
          title: Text(
            'Captain ${captain.toString()}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUI.fontSize(context, 17),
              color: Colors.grey.shade800,
            ),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: ResponsiveUI.padding(context, 6)),
            child: Wrap(
              spacing: ResponsiveUI.spacing(context, 12),
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_rounded, size: ResponsiveUI.iconSize(context, 14), color: Colors.purple.shade400),
                    SizedBox(width: ResponsiveUI.spacing(context, 4)),
                    Text(
                      '${captainOrders.length} orders',
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 13),
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.payments_rounded, size: ResponsiveUI.iconSize(context, 14), color: Colors.green.shade600),
                    SizedBox(width: ResponsiveUI.spacing(context, 4)),
                    Text(
                      '${totalAmount.toStringAsFixed(0)} EGP',
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 13),
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          children: captainOrders.map((order) {
            final statusColor = _getStatusColor(order.orderStatus ?? '');
            return Container(
              margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 10)),
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 14)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                border: Border.all(color: statusColor.withOpacity(0.2), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveUI.padding(context, 10)),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
                    ),
                    child: Icon(Icons.receipt_rounded, color: statusColor, size: ResponsiveUI.iconSize(context, 22)),
                  ),
                  SizedBox(width: ResponsiveUI.spacing(context, 12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.orderNumber}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveUI.fontSize(context, 14),
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 4)),
                        Row(
                          children: [
                            Icon(Icons.table_restaurant_rounded, size: ResponsiveUI.iconSize(context, 12), color: Colors.grey.shade500),
                            SizedBox(width: ResponsiveUI.spacing(context, 4)),
                            Text(
                              'Table: ${order.table?.toString() ?? 'N/A'}',
                              style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 12), color: Colors.grey.shade600),
                            ),
                            SizedBox(width: ResponsiveUI.spacing(context, 8)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUI.padding(context, 6),
                                vertical: ResponsiveUI.padding(context, 2),
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 4)),
                              ),
                              child: Text(
                                order.orderStatus?.toUpperCase() ?? 'UNKNOWN',
                                style: TextStyle(
                                  fontSize: ResponsiveUI.fontSize(context, 9),
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${order.amount} EGP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUI.fontSize(context, 15),
                      color: AppColors.colorPrimary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String message}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 32)),
        child: SingleChildScrollView(  // إضافة: للسماح بالتمرير في حال overflow
          physics: const NeverScrollableScrollPhysics(),  // لا scroll إلا إذا لزم (للحفاظ على centering)
          child: ConstrainedBox(  // إضافة: لضمان الحد الأدنى للارتفاع
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.4,  // ارتفاع أدنى responsive (40% من الشاشة)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,  // تغيير: min بدلاً من max لتجنب التمدد الزائد
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 24)),  // تقليل: من 32 إلى 24 للتوفير في المساحة
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.colorPrimaryLight.withOpacity(0.3), AppColors.colorPrimaryLight],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                      icon,
                      size: ResponsiveUI.iconSize(context, 64),  // تقليل: من 80 إلى 64 للشاشات الصغيرة (ResponsiveUI يتعامل)
                      color: AppColors.colorPrimary
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 20)),  // تقليل: من 24 إلى 20
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 20),  // تقليل: من 22 إلى 20
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 10)),  // تقليل: من 12 إلى 10
                Text(
                  message,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),  // تقليل: من 15 إلى 14
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade700;
      case 'confirmed':
        return Colors.blue.shade600;
      case 'processing':
        return Colors.purple.shade600;
      case 'out_for_delivery':
        return Colors.indigo.shade600;
      case 'delivered':
      case 'completed':
        return Colors.green.shade600;
      case 'returned':
        return Colors.brown.shade600;
      case 'failed':
        return Colors.red.shade700;
      case 'refund':
        return Colors.amber.shade700;
      case 'canceled':
      case 'cancelled':
        return Colors.grey.shade600;
      case 'scheduled':
        return Colors.teal.shade600;
      default:
        return Colors.grey;
    }
  }
}