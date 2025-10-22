import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/error_widget.dart';
import '../cubit/order_cubit.dart';
import '../cubit/order_state.dart';
import '../model/order_item_model.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().getOrderItem(orderId: widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.colorPrimary,
              ),
            );
          }

          if (state is OrderError) {
            return Center(
              child: ErrorWidgetDine(message: state.message),
            );
          }

          if (state is OrderSuccess) {
            final orderItem = context
                .read<OrderCubit>()
                .orderItem;

            if (orderItem == null) {
              return const Center(
                child: Text('No order data available'),
              );
            }

            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(orderItem),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Information Card
                        if (orderItem.order != null)
                          _buildOrderInfoCard(orderItem.order!),

                        const SizedBox(height: 16),

                        // Order Status List
                        if (orderItem.orderStatus != null &&
                            orderItem.orderStatus!.isNotEmpty)

                        const SizedBox(height: 16),

                        // Preparing Time
                        if (orderItem.preparingTime != null)
                          _buildPreparingTimeCard(orderItem.preparingTime!),

                        const SizedBox(height: 16),

                        // Products Card
                        if (orderItem.order?.orderDetailsData != null &&
                            orderItem.order!.orderDetailsData!.isNotEmpty)
                          _buildProductsCard(orderItem.order!
                              .orderDetailsData!),

                        const SizedBox(height: 16),

                        // Deliveries Card
                        if (orderItem.deliveries != null &&
                            orderItem.deliveries!.isNotEmpty)

                        const SizedBox(height: 16),

                        // Branches Card
                        if (orderItem.branches != null &&
                            orderItem.branches!.isNotEmpty)
                          // _buildBranchesCard(orderItem.branches!),

                        const SizedBox(height: 16),

                        // Log Order Card
                        if (orderItem.logOrder != null &&
                            orderItem.logOrder!.isNotEmpty)
                          _buildLogOrderCard(orderItem.logOrder!),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: Text('Unknown state'),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(OrderItemModel orderItem) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.colorPrimary,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          orderItem.order?.orderNumber ?? 'Order Details',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.colorPrimary, AppColors.colorPrimary],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard(Order order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.colorPrimary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.colorPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Order Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.colorPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow('Order Number', order.orderNumber ?? 'N/A'),
                _buildInfoRow('Order Status', order.orderStatus ?? 'N/A'),
                _buildInfoRow('Order Type', order.orderType ?? 'N/A'),
                _buildInfoRow('Payment Status', order.statusPayment ?? 'N/A'),
                _buildInfoRow('Amount', '${order.amount ?? 0} EGP'),
                _buildInfoRow('Total Tax', '${order.totalTax ?? 0} EGP'),
                _buildInfoRow(
                    'Total Discount', '${order.totalDiscount ?? 0} EGP'),
                _buildInfoRow(
                    'Coupon Discount', '${order.couponDiscount ?? 0} EGP'),
                _buildInfoRow('Points', '${order.points ?? 0}'),
                _buildInfoRow('Source', order.source ?? 'N/A'),
                _buildInfoRow('Created At', _formatDate(order.createdAt ?? '')),
                _buildInfoRow('Order Date', _formatDate(order.orderDate ?? '')),
                if (order.notes != null)
                  _buildInfoRow('Notes', order.notes.toString()),
                if (order.rejectedReason != null)
                  _buildInfoRow(
                      'Rejected Reason', order.rejectedReason.toString()),
                if (order.transactionId != null)
                  _buildInfoRow(
                      'Transaction ID', order.transactionId.toString()),

                // User Information
                if (order.user != null) ...[
                  const Divider(height: 32),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Customer Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.colorPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Customer Name',
                    '${order.user!.fName ?? ''} ${order.user!.lName ?? ''}'
                        .trim(),
                  ),
                  _buildInfoRow('Phone', order.user!.phone ?? 'N/A'),
                  _buildInfoRow('Email', order.user!.email ?? 'N/A'),
                  _buildInfoRow('Wallet', '${order.user!.wallet ?? 0} EGP'),
                  _buildInfoRow('Points', '${order.user!.points ?? 0}'),
                ],

                // Branch Information
                if (order.branch != null) ...[
                  const Divider(height: 32),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Branch Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.colorPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Branch Name', order.branch!.name ?? 'N/A'),
                  _buildInfoRow('Address', order.branch!.address ?? 'N/A'),
                  _buildInfoRow('Phone', order.branch!.phone ?? 'N/A'),
                  _buildInfoRow('Email', order.branch!.email ?? 'N/A'),
                ],

                // Payment Method
                if (order.paymentMethod != null) ...[
                  const Divider(height: 32),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.colorPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Payment Method',
                    order.paymentMethod!.name ?? 'N/A',
                  ),
                ],

                // Schedule
                if (order.schedule != null) ...[
                  const Divider(height: 32),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Schedule',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.colorPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Schedule', order.schedule!.name ?? 'N/A'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPreparingTimeCard(PreparingTime time) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.colorPrimary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.colorPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Preparing Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.colorPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimeItem(
                    'Days', '${time.days ?? 0}', Icons.calendar_today),
                _buildTimeItem('Hours', '${time.hours ?? 0}', Icons.schedule),
                _buildTimeItem('Minutes', '${time.minutes ?? 0}', Icons.timer),
                _buildTimeItem(
                    'Seconds', '${time.seconds ?? 0}', Icons.access_time),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.colorPrimary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.colorPrimary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.colorPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProductsCard(List<OrderDetailsData> products) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.colorPrimary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.colorPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Order Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.colorPrimary,
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final productData = products[index];
              if (productData.product != null &&
                  productData.product!.isNotEmpty) {
                final productItem = productData.product![0];
                final product = productItem.product;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            image: product?.imageLink != null
                                ? DecorationImage(
                              image: NetworkImage(product!.imageLink!),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: product?.imageLink == null
                              ? const Icon(Icons.fastfood, size: 30)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product?.name ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Quantity: ${productItem.count ?? 0}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${product?.priceAfterTax ?? product?.price ??
                                    0} EGP',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.colorPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (productItem.notes != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                                Icons.note, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Notes: ${productItem.notes}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogOrderCard(List<dynamic> logOrders) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.colorPrimary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.colorPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Order Logs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.colorPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              logOrders.isEmpty ? 'No logs available' : logOrders.toString(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    if (date.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime
          .hour}:${dateTime.minute}';
    } catch (e) {
      return date;
    }
  }

  String _formatStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

}