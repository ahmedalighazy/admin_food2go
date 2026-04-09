abstract class OrderState {}

class OrderInitial extends OrderState {}

// ── Count States ──────────────────────────
class OrderCountLoading extends OrderState {}
class OrderCountSuccess extends OrderState {}
class OrderCountError extends OrderState {
  final String message;
  OrderCountError({required this.message});
}

// ── List States ───────────────────────────
class OrderListLoading extends OrderState {}
class OrderListSuccess extends OrderState {}
class OrderListEmpty extends OrderState {}
class OrderListError extends OrderState {
  final String message;
  OrderListError({required this.message});
}

// ── Item States ───────────────────────────
class OrderItemLoading extends OrderState {}
class OrderItemSuccess extends OrderState {}
class OrderItemError extends OrderState {
  final String message;
  OrderItemError({required this.message});
}

// ── Invoice States ────────────────────────
class OrderInvoiceLoading extends OrderState {}
class OrderInvoiceSuccess extends OrderState {}
class OrderInvoiceError extends OrderState {
  final String message;
  OrderInvoiceError({required this.message});
}

// ── Status Change States ──────────────────
class OrderStatusChangeLoading extends OrderState {}
class OrderStatusChangeSuccess extends OrderState {}
class OrderStatusChangeError extends OrderState {
  final String message;
  OrderStatusChangeError({required this.message});
}

// ── Legacy للـ OrderTab ───────────────────
class OrderLoading extends OrderState {}
class OrderSuccess extends OrderState {}
class OrderError extends OrderState {
  final String message;
  OrderError({required this.message});
}