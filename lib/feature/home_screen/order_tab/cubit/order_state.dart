abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderSuccess extends OrderState {}

class OrderListLoading extends OrderState {}

class OrderListSuccess extends OrderState {}

class OrderListEmpty extends OrderState {}

class OrderInvoiceLoading extends OrderState {}

class OrderInvoiceSuccess extends OrderState {}

class OrderError extends OrderState {
  final String message;

  OrderError({required this.message});
}
