import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
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
      'value': 'failed_to_deliver',
      'label': 'Failed',
      'icon': Icons.error_outline,
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

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Orders> _filteredOrders = [];

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

    // ✅ الاتنين مفيش تعارض دلوقتي
    final cubit = context.read<OrderCubit>();
    cubit.refreshOrdersCount(); // بيعمل OrderCountLoading مش OrderLoading
    _loadOrders();              // بيعمل OrderListLoading

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _filterOrders();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadOrders() {
    final cubit = context.read<OrderCubit>();
    if (selectedStatus != 'all') {
      cubit.getOrdersByStatus(orderStatus: selectedStatus);
    }
  }

  void _filterOrders() {
    final cubit = context.read<OrderCubit>();
    final allOrders = cubit.orders?.orders ?? [];
    if (_searchQuery.isEmpty) {
      _filteredOrders = allOrders;
    } else {
      _filteredOrders = allOrders.where((order) {
        final orderNumber = (order.orderNumber ?? '').toLowerCase();
        final customerName = '${order.user?.fName ?? ''} ${order.user?.lName ?? ''}'.toLowerCase().trim();
        final phone = (order.user?.phone ?? '').toLowerCase();
        return orderNumber.contains(_searchQuery) ||
            customerName.contains(_searchQuery) ||
            phone.contains(_searchQuery);
      }).toList();
    }
  }

  int _getCountForStatus(String status, dynamic orderList) {
    if (orderList == null) return 0;
    switch (status) {
      case 'pending':
        return orderList.pending ?? 0;
      case 'confirmed':
        return orderList.confirmed ?? 0;
      case 'processing':
        return orderList.processing ?? 0;
      case 'out_for_delivery':
        return orderList.outForDelivery ?? 0;
      case 'delivered':
        return orderList.delivered ?? 0;
      case 'scheduled':
        return orderList.scheduled ?? 0;
      case 'returned':
        return orderList.returned ?? 0;
      case 'failed_to_deliver':
        return orderList.faildToDeliver ?? 0;
      case 'refund':
        return orderList.refund ?? 0;
      case 'canceled':
        return orderList.canceled ?? 0;
      default:
        return 0;
    }
  }

  // Dialog to change order status
  void _showChangeStatusDialog(Orders order) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: context.read<OrderCubit>(),
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
                            Icons.sync_alt,
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
                                'Change Order Status',
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
                  // Status List
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: statusFilters.map((status) {
                          final isCurrentStatus = order.orderStatus == status['value'];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isCurrentStatus
                                  ? status['color'].withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCurrentStatus
                                    ? status['color']
                                    : Colors.grey[300]!,
                                width: isCurrentStatus ? 2 : 1,
                              ),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: status['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  status['icon'],
                                  color: status['color'],
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                status['label'],
                                style: TextStyle(
                                  fontWeight: isCurrentStatus
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isCurrentStatus
                                      ? status['color']
                                      : Colors.black87,
                                ),
                              ),
                              trailing: isCurrentStatus
                                  ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: status['color'],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Current',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                                  : const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
                              onTap: isCurrentStatus
                                  ? null
                                  : () {
                                _confirmStatusChange(
                                  dialogContext,
                                  order,
                                  status['value'],
                                  status['label'],
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Confirm status change
  void _confirmStatusChange(
      BuildContext dialogContext,
      Orders order,
      String newStatus,
      String statusLabel,
      ) {
    showDialog(
      context: context,
      builder: (BuildContext confirmContext) {
        return BlocProvider.value(
          value: context.read<OrderCubit>(),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.colorPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.colorPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Confirm Status Change',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to change the status of order ${order.orderNumber} to:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.colorPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.colorPrimary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(newStatus),
                        color: AppColors.colorPrimary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        statusLabel,
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
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(confirmContext),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              BlocConsumer<OrderCubit, OrderState>(
                listener: (context, state) {
                  if (state is OrderStatusChangeSuccess) {
                    Navigator.pop(confirmContext); // Close confirm dialog
                    Navigator.pop(dialogContext); // Close status list dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: AwesomeSnackbarContent(
                          title: 'Success!',
                          message: 'Order status changed successfully to $statusLabel',
                          contentType: ContentType.success,
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                    );
                    _loadOrders();
                    context.read<OrderCubit>().refreshOrdersCount(); // ✅ بدل getOrdersCount
                  }
                  if (state is OrderStatusChangeError) {
                    String message = state.message;
                    if (message.contains('500') || message.contains('Laravel')) {
                      message = 'Server error (500). Please try again.';
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: AwesomeSnackbarContent(
                          title: 'Error!',
                          message: message,
                          contentType: ContentType.failure,
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is OrderStatusChangeLoading) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.colorPrimary,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }
                  return ElevatedButton(
                    onPressed: () {
                      context.read<OrderCubit>().changeOrderStatus(
                        orderId: order.id!.toInt(),
                        newStatus: newStatus,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.colorPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInvoiceDialog(Orders order) {
    final cubit = context.read<OrderCubit>();
    cubit.clearInvoice();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        cubit.getOrderInvoice(orderId: order.id!.toInt());
        return BlocProvider.value(
          value: cubit,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- زر الإغلاق ---
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ),

                  // --- محتوى الفاتورة ---
                  Flexible(
                    child: BlocBuilder<OrderCubit, OrderState>(
                      buildWhen: (previous, current) {
                        return current is OrderInvoiceLoading ||
                            current is OrderInvoiceSuccess ||
                            current is OrderInvoiceError;
                      },
                      builder: (context, state) {
                        if (state is OrderInvoiceLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(
                              child: CircularProgressIndicator(color: Colors.black),
                            ),
                          );
                        }
                        if (state is OrderInvoiceSuccess) {
                          final invoice = cubit.invoice;
                          final invoiceData = invoice?.order;

                          final String orderNum = invoiceData?.orderNumber ?? order.orderNumber ?? 'N/A';
                          final String orderDate = invoiceData?.createdAt ?? order.createdAt ?? '';
                          final String fName = invoiceData?.user?.fName ?? order.user?.fName ?? '';
                          final String lName = invoiceData?.user?.lName ?? order.user?.lName ?? '';
                          final String phone = invoiceData?.user?.phone ?? order.user?.phone ?? 'N/A';
                          final String type = invoiceData?.orderType ?? 'N/A';
                          final bool isDelivery = type.toLowerCase() == 'delivery';
                          final String paymentStat = (invoiceData?.paymentStatus == 1 || invoiceData?.statusPayment == 'paid') ? 'Paid' : 'UnPaid';

                          return SingleChildScrollView(
                            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Logo and Header (Uncomment if needed)
                                // Center( ... ),

                                const SizedBox(height: 10),
                                _buildDashedLine(),
                                const SizedBox(height: 10),

                                // 2. Order Information
                                _buildReceiptInfoRow('Order #:', orderNum),
                                _buildReceiptInfoRow('Date:', _formatReceiptDate(orderDate)),
                                _buildReceiptInfoRow('Time:', _formatReceiptTime(orderDate)),
                                _buildReceiptInfoRow('Client:', '$fName $lName'.trim()),
                                _buildReceiptInfoRow('Phone:', phone),
                                _buildReceiptInfoRow('Order Type:', _formatStatus(type)),
                                _buildReceiptInfoRow('Payment:', paymentStat),

                                const SizedBox(height: 10),
                                _buildDashedLine(),

                                // 3. Delivery Address
                                if (isDelivery && order.address?.zone?.zone != null) ...[
                                  const SizedBox(height: 10),
                                  const Text('Delivery Address:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text('Zone: ${order.address!.zone!.zone}', style: const TextStyle(fontSize: 12)),
                                  const SizedBox(height: 10),
                                  _buildDashedLine(),
                                ],

                                const SizedBox(height: 10),

                                // 4. Items Table Header
                                Row(
                                  children: const [
                                    Expanded(flex: 3, child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
                                    Expanded(flex: 1, child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                                    Expanded(flex: 2, child: Text('Price', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                                    Expanded(flex: 2, child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                ),
                                const Divider(color: Colors.black, thickness: 1.5),

                                // 5. Items List
                                if (invoiceData?.orderDetails != null)
                                  ...invoiceData!.orderDetails!.map((detail) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // 1. المنتج الأساسي
                                          if (detail.product != null && detail.product!.isNotEmpty)
                                            ...detail.product!.map((prodItem) {
                                              final name = prodItem.product?.name ?? 'Unknown Item';
                                              final qty = prodItem.count ?? 1;
                                              final price = prodItem.product?.price ?? 0;
                                              final total = price * qty;
                                              return Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text('$qty', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(price.toStringAsFixed(2), textAlign: TextAlign.right, style: const TextStyle(fontSize: 13)),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(total.toStringAsFixed(2), textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                                  ),
                                                ],
                                              );
                                            }),

                                          // 2. التغييرات (Variations) - الدخول جوا الـ options
                                          if (detail.variations != null && detail.variations!.isNotEmpty)
                                            ...detail.variations!.expand<Widget>((v) {
                                              // لو الـ variation جواه قائمة options
                                              if (v is Map && v['options'] != null && v['options'] is List) {
                                                // final varName = v['name'] ?? '';
                                                return (v['options'] as List).map<Widget>((opt) {
                                                  final optName = opt['name'] ?? '';
                                                  final optPrice = opt['price'];
                                                  final priceStr = (optPrice != null && optPrice.toString() != '0' && optPrice.toString() != '0.0') ? ' (+${optPrice})' : '';
                                                  return _buildSubItemRow('-$optName$priceStr');
                                                });
                                              } else if (v is Map) {
                                                return [_buildSubItemRow('- ${v['name'] ?? v.toString()}')];
                                              }
                                              return const [];
                                            }),

                                          // 3. الإضافات (Addons)
                                          if (detail.addons != null && detail.addons!.isNotEmpty)
                                            ...detail.addons!.map((a) {
                                              if (a is Map) {
                                                final name = a['name'] ?? '';
                                                final price = a['price'];
                                                final priceStr = (price != null && price.toString() != '0' && price.toString() != '0.0') ? ' (+${price})' : '';
                                                return _buildSubItemRow('+ $name$priceStr');
                                              }
                                              return _buildSubItemRow('+ $a');
                                            }),

                                          // 4. إضافات أخرى (Extras) - لو موجودة
                                          if (detail.extras != null && detail.extras!.isNotEmpty)
                                            ...detail.extras!.map((e) {
                                              if (e is Map) {
                                                final name = e['name'] ?? '';
                                                final price = e['price'];
                                                final priceStr = (price != null && price.toString() != '0' && price.toString() != '0.0') ? ' (+${price})' : '';
                                                return _buildSubItemRow('+ $name$priceStr');
                                              }
                                              return _buildSubItemRow('+ $e');
                                            }),
                                        ],
                                      ),
                                    );
                                  }).toList(),

                                const Divider(color: Colors.black, thickness: 1),

                                // 6. Calculations
                                _buildReceiptCalculationRow('Total Product Price', (invoiceData?.amount ?? order.amount ?? 0).toStringAsFixed(2)),
                                _buildReceiptCalculationRow('Tax %:', (invoiceData?.totalTax ?? 0).toStringAsFixed(2)),

                                if ((invoiceData?.totalDiscount ?? 0) > 0 || !isDelivery)
                                  _buildReceiptCalculationRow('Discount', '-${(invoiceData?.totalDiscount ?? 0).toStringAsFixed(2)}'),

                                if (isDelivery)
                                  _buildReceiptCalculationRow('Delivery Fee', '15.00'), // عدلها حسب قيمة التوصيل عندك

                                const Divider(color: Colors.black, thickness: 2),

                                // 7. Grand Total
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Grand Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text(
                                      (invoiceData?.amount ?? order.amount ?? 0).toStringAsFixed(2),
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),
                                _buildDashedLine(),
                                const SizedBox(height: 15),

                                // 8. Footer
                                const Center(
                                  child: Text('Thank you for your order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                                const Center(
                                  child: Text('Powered by Food2Go', style: TextStyle(fontSize: 11)),
                                ),
                                const Center(
                                  child: Text('food2go.online', style: TextStyle(fontSize: 11)),
                                ),
                              ],
                            ),
                          );
                        }

                        if (state is OrderInvoiceError) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, size: 50, color: Colors.red),
                                const SizedBox(height: 16),
                                Text(state.message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => context.read<OrderCubit>().getOrderInvoice(orderId: order.id!.toInt()),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                                  child: const Text('Retry', style: TextStyle(color: Colors.white)),
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
      context.read<OrderCubit>().clearInvoice();
    });
  }

// دالة مساعدة لعرض الإضافات تحت المنتج بشكل متناسق
  Widget _buildSubItemRow(String text) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, top: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(decoration: BoxDecoration(color: Colors.black87)),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }

  // دالة لإنشاء صفوف بيانات الفاتورة (Order #, Client, etc.)
  Widget _buildReceiptInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
          Expanded(
            child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, color: Colors.black)),
          ),
        ],
      ),
    );
  }

  // دالة لإنشاء صفوف الحسابات (Total, Tax, Discount)
  Widget _buildReceiptCalculationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          Text(value, style: const TextStyle(fontSize: 13, color: Colors.black)),
        ],
      ),
    );
  }

  // دالة مساعدة لتنسيق الوقت من الـ Timestamp
  String _formatReceiptTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateString);
      // تنسيق بسيط للوقت (e.g. 11:19 PM)
      String hour = dateTime.hour > 12 ? (dateTime.hour - 12).toString().padLeft(2, '0') : dateTime.hour.toString().padLeft(2, '0');
      if (hour == '00') hour = '12';
      String min = dateTime.minute.toString().padLeft(2, '0');
      String amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$min $amPm';
    } catch (e) {
      return '';
    }
  }

  // دالة مساعدة لتنسيق التاريخ
  String _formatReceiptDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
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

  Widget _buildInvoiceRow(String label, String value,
      {bool isBold = false, bool isTotal = false}) {
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
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
              child: _buildSearchBar(),
            ),
          ),
          BlocConsumer<OrderCubit, OrderState>(
            listener: (context, state) {
              if (state is OrderListError) {
                String message = state.message;
                if (message.contains('500') || message.contains('Laravel')) {
                  message = 'Server error (500). Please try again.';
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: AwesomeSnackbarContent(
                      title: 'Error!',
                      message: message,
                      contentType: ContentType.failure,
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                );
              }
              if (state is OrderListSuccess || state is OrderListEmpty) {
                _filterOrders();
              }
            },
            builder: (context, state) {
              final cubit = context.read<OrderCubit>();
              
              if (state is OrderListLoading) {
                return SliverToBoxAdapter(child: _buildLoadingShimmer());
              }
              if (state is OrderListError) {
                return SliverFillRemaining(
                  child: ErrorWidgetDine(
                    message: state.message,
                    onRetry: () {
                      cubit.getOrdersByStatus(orderStatus: selectedStatus);
                    },
                  ),
                );
              }
              final orderList = _filteredOrders;
              if (orderList.isEmpty) {
                String message = 'There are no orders with status "$selectedStatus".';
                if (_searchQuery.isNotEmpty) {
                  message = 'No orders found matching "$_searchQuery".';
                }
                return SliverFillRemaining(
                  child: EmptyStateDine(
                    icon: _searchQuery.isNotEmpty ? Icons.search_off : Icons.receipt_long_outlined,
                    title: _searchQuery.isNotEmpty ? 'No Results Found' : 'No Orders Found',
                    message: message,
                  ),
                );
              }
              return SliverPadding(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
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
                          position: Tween<Offset>(
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
                    },
                    childCount: orderList.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by order number, customer name, or phone...',
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.colorPrimary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
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
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 20,
          ),
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
              colors: [
                AppColors.colorPrimary,
                AppColors.colorPrimary,
              ],
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
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        final cubit = context.read<OrderCubit>();
        final overviewList = cubit.orderList;
        return Container(
          height: 120,
          margin: const EdgeInsets.only(top: 16, bottom: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: statusFilters.length,
            itemBuilder: (context, index) {
              final filter = statusFilters[index];
              final count = _getCountForStatus(filter['value'], overviewList);
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
                    width: 110,
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
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            filter['icon'],
                            color: isSelected
                                ? Colors.white
                                : filter['color'],
                            size: 30,
                          ),
                          Text(
                            filter['label'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : filter['color'],
                              fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                              fontSize: 11,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.25)
                                  : filter['color'].withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.4)
                                    : filter['color'].withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : filter['color'],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildOrderCountBadge() {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        final cubit = context.read<OrderCubit>();
        final orderCount = _filteredOrders.length;
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
                      'Total ${ _formatStatus(selectedStatus)} Orders',
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
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
                      if (order.address?.zone?.zone != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRowEnhanced(
                          Icons.location_on,
                          order.address!.zone!.zone!,
                          AppColors.colorPrimary,
                        ),
                      ],
                      const Divider(height: 24),
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
                                  Text(
                                    'Points',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.colorPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${order.points}',
                                    style: TextStyle(
                                      fontSize: 18,
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
                      // Two buttons: Invoice and Change Status
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showInvoiceDialog(order),
                              icon: const Icon(Icons.receipt_long, size: 18),
                              label: const Text('Invoice'),
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showChangeStatusDialog(order),
                              icon: const Icon(Icons.sync_alt, size: 18),
                              label: const Text('Status'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.colorPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: AppColors.colorPrimary,
                                    width: 2,
                                  ),
                                ),
                                elevation: 0,
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
      case 'failed_to_deliver':
        return Icons.error_outline;
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
          (word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase(),
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
      _loadOrders();
    });
  }
}