abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderSuccess extends OrderState {}

class OrderError extends OrderState {
  final String message;
  OrderError({required this.message});
}

class OrderListLoading extends OrderState {}

class OrderListSuccess extends OrderState {}

class OrderListEmpty extends OrderState {}

class OrderInvoiceLoading extends OrderState {}

class OrderInvoiceSuccess extends OrderState {}

// New states for status change
class OrderStatusChangeLoading extends OrderState {}

class OrderStatusChangeSuccess extends OrderState {}