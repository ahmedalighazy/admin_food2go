import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_ui.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../cubit/order_cubit.dart';
import '../cubit/order_state.dart';
import '../model/order_list.dart';
import 'order_details_screen.dart';

class OrderListScreen extends StatefulWidget {
  final String? orderStatus;

  const OrderListScreen({super.key, this.orderStatus});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with SingleTickerProviderStateMixin {
  String selectedStatus = 'pending';
  late AnimationController _animationController;

  final List<Map<String, dynamic>> statusFilters = [
    {
      'value': 'pending',
      'label': 'Pending',
      'icon': Icons.hourglass_empty,
      'color': AppColors.colorPrimary,
    },
    {
      'value': 'confirmed',
      'label': 'Confirmed',
      'icon': Icons.check_circle_outline,
      'color': AppColors.colorPrimary,
    },
    {
      'value': 'processing',
      'label': 'Processing',
      'icon': Icons.sync,
      'color': AppColors.colorPrimary,
    },
    {
      'value': 'out_for_delivery',
      'label': 'Out for Delivery',
      'icon': Icons.local_shipping,
      'color': AppColors.colorPrimary,
    },
    {
      'value': 'delivered',
      'label': 'Delivered',
      'icon': Icons.done_all,
      'color': AppColors.colorPrimary,
    },
    {
      'value': 'scheduled',
      'label': 'Scheduled',
      'icon': Icons.schedule,
      'color': AppColors.colorPrimary,
    },
    {
      'value': 'returned',
      'label': 'Returned',
      'icon': Icons.keyboard_return,
      'color': AppColors.colorPrimary,
    },
    {
      'value': 'refund',
      'label': 'Refund',
      'icon': Icons.money_off,
      'color': AppColors.colorPrimary,
    },
    {
      'value': 'canceled',
      'label': 'Canceled',
      'icon': Icons.cancel_outlined,
      'color': AppColors.colorPrimary,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();

    if (widget.orderStatus != null) {
      selectedStatus = widget.orderStatus!;
    } else {
      selectedStatus = 'pending';
    }
    _loadOrders();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadOrders() {
    final cubit = context.read<OrderCubit>();
    if (selectedStatus != 'all') {
      cubit.getOrdersByStatus(orderStatus: selectedStatus);
    }
  }

  void _showInvoiceDialog(Orders order) {
    // Clear previous invoice data before showing dialog
    final cubit = context.read<OrderCubit>();
    cubit.clearInvoice();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        // Load invoice data immediately
        cubit.getOrderInvoice(orderId: order.id!.toInt());

        return BlocProvider.value(
          value: cubit,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.colorPrimary,
                          AppColors.colorPrimary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.receipt_long,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Invoice Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                order.orderNumber ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Flexible(
                    child: BlocBuilder<OrderCubit, OrderState>(
                      buildWhen: (previous, current) {
                        // Rebuild only for invoice-related states
                        return current is OrderInvoiceLoading ||
                            current is OrderInvoiceSuccess ||
                            (current is OrderError && previous is OrderInvoiceLoading);
                      },
                      builder: (context, state) {
                        if (state is OrderInvoiceLoading) {
                          return Container(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: AppColors.colorPrimary,
                                ),
                                const SizedBox(height: 16),
                                const Text('Loading invoice...'),
                              ],
                            ),
                          );
                        }

                        if (state is OrderInvoiceSuccess) {
                          final cubit = context.read<OrderCubit>();
                          final invoice = cubit.invoice;

                          if (invoice == null) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('No invoice data available'),
                            );
                          }

                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Invoice Info
                                _buildInvoiceSection(
                                  'Invoice Information',
                                  [
                                    _buildInvoiceRow('Invoice Number', invoice.order?.toString() ?? 'N/A'),
                                    _buildInvoiceRow('Order Number', order.orderNumber ?? 'N/A'),
                                    _buildInvoiceRow('Date', _formatDate(order.createdAt ?? '')),
                                    _buildInvoiceRow('Status', _formatStatus(order.orderStatus ?? 'N/A')),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Customer Info
                                _buildInvoiceSection(
                                  'Customer Information',
                                  [
                                    _buildInvoiceRow('Name', '${order.user?.fName ?? ''} ${order.user?.lName ?? ''}'.trim()),
                                    _buildInvoiceRow('Phone', order.user?.phone ?? 'N/A'),
                                    if (order.address?.zone?.zone != null)
                                      _buildInvoiceRow('Location', order.address!.zone!.zone!),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Payment Details
                                _buildInvoiceSection(
                                  'Payment Details',
                                  [
                                    _buildInvoiceRow('Subtotal', '${order.amount ?? 0} EGP', isBold: true),
                                    if (order.points != null && order.points! > 0)
                                      _buildInvoiceRow('Points Used', '${order.points}', isBold: false),
                                    const Divider(height: 20),
                                    _buildInvoiceRow('Total Amount', '${order.amount ?? 0} EGP', isBold: true, isTotal: true),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }

                        if (state is OrderError) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 60,
                                  color: Colors.red[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<OrderCubit>().getOrderInvoice(orderId: order.id!.toInt());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.colorPrimary,
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      // Clear invoice data when dialog is closed
      context.read<OrderCubit>().clearInvoice();
    });
  }

  Widget _buildInvoiceSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.colorPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value, {bool isBold = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              color: Colors.grey[700],
              fontWeight: isBold || isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isBold || isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? AppColors.colorPrimary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildStatusFilter()),
          SliverToBoxAdapter(child: _buildOrderCountBadge()),
          BlocConsumer<OrderCubit, OrderState>(
            listener: (context, state) {
              if (state is OrderError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(child: Text(state.message)),
                      ],
                    ),
                    backgroundColor: Colors.red[700],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is OrderListLoading) {
                return SliverToBoxAdapter(child: _buildLoadingShimmer());
              }

              if (state is OrderError && context.read<OrderCubit>().orders == null) {
                return SliverFillRemaining(
                  child: ErrorWidgetDine(message: state.message),
                );
              }

              final cubit = context.read<OrderCubit>();
              final orderList = cubit.orders?.orders ?? [];

              if (orderList.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyStateDine(
                    icon: Icons.receipt_long_outlined,
                    title: 'No Orders Found',
                    message:
                    'There are no orders with status "$selectedStatus".',
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return FadeTransition(
                      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            (index / orderList.length) * 0.5,
                            1.0,
                            curve: Curves.easeOut,
                          ),
                        ),
                      ),
                      child: SlideTransition(
                        position:
                        Tween<Offset>(
                          begin: const Offset(0.3, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(
                              (index / orderList.length) * 0.5,
                              1.0,
                              curve: Curves.easeOut,
                            ),
                          ),
                        ),
                        child: _buildEnhancedOrderCard(
                          context,
                          orderList[index],
                        ),
                      ),
                    );
                  }, childCount: orderList.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
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
        title: const Text(
          'Order Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.colorPrimary, AppColors.colorPrimary],
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
              Positioned(
                left: -50,
                bottom: -50,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: 90,
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: statusFilters.length,
        itemBuilder: (context, index) {
          final filter = statusFilters[index];
          final isSelected = selectedStatus == filter['value'];

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedStatus = filter['value'];
                  _loadOrders();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 100,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      filter['color'],
                      filter['color'].withOpacity(0.8),
                    ],
                  )
                      : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? filter['color']
                        : filter['color'].withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? filter['color'].withOpacity(0.4)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: isSelected ? 8 : 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      filter['icon'],
                      color: isSelected ? Colors.white : filter['color'],
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      filter['label'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : filter['color'],
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCountBadge() {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        final cubit = context.read<OrderCubit>();
        final orderCount = cubit.orders?.orders?.length ?? 0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.colorPrimary.withOpacity(0.1),
                AppColors.colorPrimary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.colorPrimary.withOpacity(0.2),
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
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total ${_formatStatus(selectedStatus)} Orders',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$orderCount Orders',
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.colorPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedOrderCard(BuildContext context, Orders order) {
    final statusColor = _getStatusColor(order.orderStatus ?? '');
    final statusIcon = _getStatusIcon(order.orderStatus ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showOrderDetails(order),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: statusColor.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withOpacity(0.1),
                        statusColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(statusIcon, color: statusColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.orderNumber ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(order.createdAt ?? ''),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          _formatStatus(order.orderStatus ?? 'N/A'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Customer Info
                      _buildInfoRowEnhanced(
                        Icons.person,
                        '${order.user?.fName ?? ''} ${order.user?.lName ?? ''}'
                            .trim(),
                        AppColors.colorPrimary,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRowEnhanced(
                        Icons.phone_android,
                        order.user?.phone ?? 'N/A',
                        AppColors.colorPrimary,
                      ),

                      if (order.branch?.name != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRowEnhanced(
                          Icons.store,
                          order.branch!.name!,
                          AppColors.colorPrimary,
                        ),
                      ],

                      if (order.address?.zone?.zone != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRowEnhanced(
                          Icons.location_on,
                          order.address!.zone!.zone!,
                          AppColors.colorPrimary,
                        ),
                      ],

                      const Divider(height: 24),

                      // Amount Row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.colorPrimary.withOpacity(0.1),
                                    AppColors.colorPrimary.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Total Amount',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${order.amount ?? 0} EGP',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.colorPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (order.points != null && order.points! > 0) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.colorPrimary.withOpacity(0.2),
                                    AppColors.colorPrimary.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.stars,
                                    color: AppColors.colorPrimary,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${order.points}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.colorPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Invoice Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showInvoiceDialog(order),
                          icon: const Icon(Icons.receipt_long, size: 20),
                          label: const Text('View Invoice'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.colorPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRowEnhanced(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 16,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'processing':
        return Icons.sync;
      case 'out_for_delivery':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.done_all;
      case 'returned':
        return Icons.keyboard_return;
      case 'refund':
        return Icons.money_off;
      case 'canceled':
        return Icons.cancel_outlined;
      case 'scheduled':
        return Icons.schedule;
      default:
        return Icons.shopping_bag;
    }
  }

  Color _getStatusColor(String status) {
    return AppColors.colorPrimary;
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

  String _formatDate(String date) {
    if (date.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  void _showOrderDetails(Orders order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(orderId: order.id!.toInt()),
      ),
    ).then((_) {
      // Re-fetch the orders list to update the state when returning from details
      _loadOrders();
    });
  }
}