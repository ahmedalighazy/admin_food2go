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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.pendingColor;
      case 'confirmed':
        return AppColors.confirmedColor;
      case 'processing':
        return AppColors.processingColor;
      case 'out_for_delivery':
        return AppColors.outForDeliveryColor;
      case 'delivered':
        return AppColors.deliveredColor;
      case 'returned':
        return AppColors.returnedColor;
      case 'failed_to_deliver':
        return AppColors.failedColor;
      case 'refund':
        return AppColors.refundColor;
      case 'canceled':
        return AppColors.canceledColor;
      case 'scheduled':
        return AppColors.scheduledColor;
      default:
        return AppColors.colorPrimary;
    }
  }

  String _formatStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return date;
    }
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

          final orderItem = context.read<OrderCubit>().orderItem;

          if (orderItem == null || orderItem.order == null) {
            return const Center(
              child: Text('No order data available'),
            );
          }

          final order = orderItem.order!;
          final statusColor = _getStatusColor(order.orderStatus ?? '');

          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                backgroundColor: statusColor,
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
                    order.orderNumber ?? 'Order Details',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [statusColor, statusColor.withOpacity(0.8)],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -30,
                          top: -30,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status & Date Card
                      _buildStatusCard(order, statusColor),
                      const SizedBox(height: 16),

                      // Customer Information
                      if (order.user != null) _buildCustomerCard(order.user!),
                      const SizedBox(height: 16),

                      // Branch Information
                      if (order.branch != null) _buildBranchCard(order.branch!),
                      const SizedBox(height: 16),

                      // Payment Information
                      _buildPaymentCard(order),
                      const SizedBox(height: 16),

                      // Order Items
                      _buildOrderItemsCard(order),
                      const SizedBox(height: 16),

                      // Schedule Information
                      if (order.schedule != null) _buildScheduleCard(order.schedule!),
                      const SizedBox(height: 16),

                      // Preparing Time
                      if (orderItem.preparingTime != null)
                        _buildPreparingTimeCard(orderItem.preparingTime!),
                      const SizedBox(height: 16),

                      // Additional Info
                      _buildAdditionalInfoCard(order),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(Order order, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.info_outline, color: statusColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Status',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formatStatus(order.orderStatus ?? 'N/A'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow(Icons.calendar_today, 'Order Date', _formatDate(order.createdAt)),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.update, 'Last Updated', _formatDate(order.updatedAt)),
          if (order.orderDate != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.event, 'Scheduled Date', order.orderDate!),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerCard(User user) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.colorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, color: AppColors.colorPrimary, size: 28),
              ),
              const SizedBox(width: 16),
              const Text(
                'Customer Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow(Icons.badge, 'Name', '${user.fName ?? ''} ${user.lName ?? ''}'.trim()),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone, 'Phone', user.phone ?? 'N/A'),
          if (user.phone2 != null && user.phone2!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.phone_android, 'Phone 2', user.phone2!),
          ],
          if (user.email != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.email, 'Email', user.email!),
          ],
          const SizedBox(height: 12),
          _buildInfoRow(Icons.stars, 'Points', '${user.points ?? 0}'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.shopping_bag, 'Total Orders', '${user.ordersCount ?? 0}'),
        ],
      ),
    );
  }

  Widget _buildBranchCard(Branch branch) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.colorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.store, color: AppColors.colorPrimary, size: 28),
              ),
              const SizedBox(width: 16),
              const Text(
                'Branch Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow(Icons.business, 'Branch Name', branch.name ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on, 'Address', branch.address ?? 'N/A'),
          if (branch.phone != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.phone, 'Phone', branch.phone!),
          ],
          if (branch.email != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.email, 'Email', branch.email!),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.colorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.payment, color: AppColors.colorPrimary, size: 28),
              ),
              const SizedBox(width: 16),
              const Text(
                'Payment Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          if (order.paymentMethod != null)
            _buildInfoRow(Icons.account_balance_wallet, 'Payment Method', order.paymentMethod!.name ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.money, 'Subtotal', '${order.amount ?? 0} EGP'),
          if (order.totalTax != null && order.totalTax! > 0) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.receipt, 'Tax', '${order.totalTax} EGP'),
          ],
          if (order.totalDiscount != null && order.totalDiscount! > 0) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.discount, 'Discount', '${order.totalDiscount} EGP'),
          ],
          if (order.couponDiscount != null && order.couponDiscount! > 0) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.local_offer, 'Coupon Discount', '${order.couponDiscount} EGP'),
          ],
          if (order.points != null && order.points! > 0) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.stars, 'Points Used', '${order.points}'),
          ],
          const Divider(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.colorPrimary.withOpacity(0.1),
                  AppColors.colorPrimary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${order.amount ?? 0} EGP',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.colorPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard(Order order) {
    if (order.orderDetailsData == null || order.orderDetailsData!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.colorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shopping_cart, color: AppColors.colorPrimary, size: 28),
              ),
              const SizedBox(width: 16),
              const Text(
                'Order Items',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...order.orderDetailsData!.map((detail) {
            if (detail.product == null || detail.product!.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: detail.product!.map((productItem) {
                final product = productItem.product;
                if (product == null) return const SizedBox.shrink();

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      if (product.imageLink != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product.imageLink!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(Icons.fastfood, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
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
                              '${product.priceAfterTax ?? product.price ?? 0} EGP',
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
                );
              }).toList(),
            );
          }).toList(),
        ],
      ),
    );
  }


  Widget _buildScheduleCard(Schedule schedule) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.colorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.schedule, color: AppColors.colorPrimary, size: 28),
              ),
              const SizedBox(width: 16),
              const Text(
                'Schedule Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow(Icons.event, 'Schedule Name', schedule.name ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.info, 'Status', schedule.status == 1 ? 'Active' : 'Inactive'),
        ],
      ),
    );
  }

  Widget _buildPreparingTimeCard(PreparingTime preparingTime) {
    String timeString = '';
    if (preparingTime.days != null && preparingTime.days! > 0) {
      timeString += '${preparingTime.days}d ';
    }
    if (preparingTime.hours != null && preparingTime.hours! > 0) {
      timeString += '${preparingTime.hours}h ';
    }
    if (preparingTime.minutes != null && preparingTime.minutes! > 0) {
      timeString += '${preparingTime.minutes}m ';
    }
    if (preparingTime.seconds != null && preparingTime.seconds! > 0) {
      timeString += '${preparingTime.seconds}s';
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.colorPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.timer, color: AppColors.colorPrimary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preparing Time',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeString.trim().isEmpty ? 'N/A' : timeString.trim(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.colorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.info, color: AppColors.colorPrimary, size: 28),
              ),
              const SizedBox(width: 16),
              const Text(
                'Additional Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow(Icons.source, 'Order Source', order.source ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.category, 'Order Type', _formatStatus(order.orderType ?? 'N/A')),
          if (order.notes != null && order.notes.toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.notes, 'Notes', order.notes.toString()),
          ],
          if (order.transactionId != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.receipt_long, 'Transaction ID', order.transactionId.toString()),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.colorPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.colorPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}