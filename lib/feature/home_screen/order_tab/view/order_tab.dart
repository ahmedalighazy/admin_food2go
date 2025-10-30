import 'package:admin_food2go/feature/home_screen/order_tab/view/order_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_ui.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../../notifacation/view/NotificationBellIcon.dart';
import '../cubit/order_cubit.dart';
import '../cubit/order_state.dart';

class OrderTab extends StatelessWidget {
  const OrderTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderCubit()..getOrdersCount(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(context),
        // drawer: _buildDrawer(context),
        body: BlocConsumer<OrderCubit, OrderState>(
          listener: (context, state) {
            if (state is OrderError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.colorPrimary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is OrderLoading) {
              return const OverviewShimmer();
            }

            if (state is OrderError) {
              return ErrorWidgetDine(message: state.message);
            }

            if (state is OrderSuccess) {
              final cubit = OrderCubit.get(context);
              final orderList = cubit.orderList;

              if (orderList == null) {
                return const EmptyStateDine(
                  icon: Icons.shopping_bag_outlined,
                  title: 'No Orders Data',
                  message:
                  'There are no orders statistics available at the moment.',
                );
              }

              return RefreshIndicator(
                onRefresh: () => cubit.getOrdersCount(),
                color: AppColors.colorPrimary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(context, orderList.orders ?? 0),
                      SizedBox(height: ResponsiveUI.spacing(context, 16)),

                      if (orderList.start != null && orderList.end != null)
                        _buildDateRangeCard(
                          context,
                          orderList.start!,
                          orderList.end!,
                        ),

                      SizedBox(height: ResponsiveUI.spacing(context, 20)),

                      Text(
                        'Order Status Overview',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 20),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 16)),

                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: ResponsiveUI.gridColumns(context),
                        crossAxisSpacing: ResponsiveUI.spacing(context, 12),
                        mainAxisSpacing: ResponsiveUI.spacing(context, 12),
                        childAspectRatio: 1.3,
                        children: [
                          _buildStatusCard(
                            context,
                            'Pending',
                            'pending',
                            orderList.pending ?? 0,
                            Icons.schedule,
                            AppColors.colorPrimary,
                          ),
                          _buildStatusCard(
                            context,
                            'Confirmed',
                            'confirmed',
                            orderList.confirmed ?? 0,
                            Icons.check_circle_outline,
                            AppColors.colorPrimary,
                          ),
                          _buildStatusCard(
                            context,
                            'Processing',
                            'processing',
                            orderList.processing ?? 0,
                            Icons.kitchen,
                            AppColors.colorPrimary,
                          ),
                          _buildStatusCard(
                            context,
                            'Out for Delivery',
                            'out_for_delivery',
                            orderList.outForDelivery ?? 0,
                            Icons.delivery_dining,
                            AppColors.colorPrimary,
                          ),
                          _buildStatusCard(
                            context,
                            'Delivered',
                            'delivered',
                            orderList.delivered ?? 0,
                            Icons.done_all,
                            AppColors.colorPrimary,
                          ),
                          _buildStatusCard(
                            context,
                            'Scheduled',
                            'scheduled',
                            orderList.scheduled ?? 0,
                            Icons.event,
                            AppColors.colorPrimary,
                          ),
                        ],
                      ),

                      SizedBox(height: ResponsiveUI.spacing(context, 20)),

                      Text(
                        'Issues & Returns',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 20),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 16)),

                      Row(
                        children: [
                          Expanded(
                            child: _buildStatusCard(
                              context,
                              'Returned',
                              'returned',
                              orderList.returned ?? 0,
                              Icons.assignment_return,
                              AppColors.colorPrimary,
                            ),
                          ),
                          SizedBox(width: ResponsiveUI.spacing(context, 12)),
                          Expanded(
                            child: _buildStatusCard(
                              context,
                              'Failed',
                              'failed_to_deliver',
                              orderList.faildToDeliver ?? 0,
                              Icons.error_outline,
                              AppColors.colorPrimary,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: ResponsiveUI.spacing(context, 12)),

                      Row(
                        children: [
                          Expanded(
                            child: _buildStatusCard(
                              context,
                              'Refund',
                              'refund',
                              orderList.refund ?? 0,
                              Icons.money_off,
                              AppColors.colorPrimary,
                            ),
                          ),
                          SizedBox(width: ResponsiveUI.spacing(context, 12)),
                          Expanded(
                            child: _buildStatusCard(
                              context,
                              'Canceled',
                              'canceled',
                              orderList.canceled ?? 0,
                              Icons.cancel,
                              AppColors.colorPrimary,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: ResponsiveUI.spacing(context, 20)),
                    ],
                  ),
                ),
              );
            }

            return const EmptyStateDine(
              icon: Icons.shopping_bag_outlined,
              title: 'No Orders Yet',
              message: 'Start by adding some orders to see statistics here.',
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.colorPrimary,
      // leading: Builder(
      //   builder: (context) => IconButton(
      //     icon: const Icon(Icons.menu, color: Colors.white),
      //     onPressed: () => Scaffold.of(context).openDrawer(),
      //   ),
      // ),
      title: const Text(
        'Orders',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        const SizedBox(
          width: 48,
          height: 48,
          child: NotificationBellIcon(),
        ),
      ],
    );
  }

  // Widget _buildDrawer(BuildContext context) {
  //   return Drawer(
  //     child: Column(
  //       children: [
  //         Container(
  //           width: double.infinity,
  //           padding: EdgeInsets.only(
  //             top: MediaQuery.of(context).padding.top + 20,
  //             bottom: 20,
  //             left: 20,
  //             right: 20,
  //           ),
  //           decoration: BoxDecoration(
  //             gradient: LinearGradient(
  //               colors: [AppColors.colorPrimary, AppColors.colorPrimary],
  //               begin: Alignment.topLeft,
  //               end: Alignment.bottomRight,
  //             ),
  //           ),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               const SizedBox(height: 16),
  //               const Text(
  //                 'Order List',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         Expanded(
  //           child: ListView(
  //             padding: EdgeInsets.zero,
  //             children: [
  //               _buildDrawerItem(
  //                 context,
  //                 icon: Icons.shopping_cart,
  //                 title: 'All Orders',
  //                 isSelected: false,
  //                 onTap: () {
  //                   Navigator.pop(context); // Close drawer first
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) => BlocProvider(
  //                         create: (context) => OrderCubit(),
  //                         child: const OrderListScreen(),
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget _buildDrawerItem(
  //     BuildContext context, {
  //       required IconData icon,
  //       required String title,
  //       required VoidCallback onTap,
  //       bool isSelected = false,
  //       Color? iconColor,
  //     }) {
  //   return ListTile(
  //     leading: Icon(
  //       icon,
  //       color: isSelected
  //           ? AppColors.colorPrimary
  //           : (iconColor ?? Colors.grey[700]),
  //     ),
  //     title: Text(
  //       title,
  //       style: TextStyle(
  //         color: isSelected ? AppColors.colorPrimary : Colors.grey[800],
  //         fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  //         fontSize: 16,
  //       ),
  //     ),
  //     selected: isSelected,
  //     selectedTileColor: AppColors.colorPrimary.withOpacity(0.1),
  //     onTap: onTap,
  //     contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
  //   );
  // }

  Widget _buildHeaderCard(BuildContext context, num totalOrders) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 20),
        vertical: ResponsiveUI.padding(context, 16),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.colorPrimary, AppColors.colorPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 16),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorPrimary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart,
              size: ResponsiveUI.iconSize(context, 32),
              color: Colors.white,
            ),
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Orders',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 4)),
                Text(
                  '$totalOrders',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 32),
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeCard(BuildContext context, String start, String end) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.colorPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 16),
        ),
        border: Border.all(color: AppColors.colorPrimary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.date_range,
            color: AppColors.colorPrimary,
            size: ResponsiveUI.iconSize(context, 24),
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Period',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 12),
                    color: AppColors.colorPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 4)),
                Text(
                  '$start → $end',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    color: AppColors.colorPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
      BuildContext context,
      String title,
      String statusValue,
      num count,
      IconData icon,
      Color color,
      ) {
    return InkWell(
      onTap: () {
        // Navigate to OrderListScreen with the specific status
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => OrderCubit(),
              child: OrderListScreen(orderStatus: statusValue),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
      child: Container(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 10)),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: ResponsiveUI.iconSize(context, 24),
              ),
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 8)),
            Text(
              '$count',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 4)),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 11),
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}