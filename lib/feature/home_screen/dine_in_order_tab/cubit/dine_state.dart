abstract class DineState {}

class DineInitial extends DineState {}

class DineLoading extends DineState {}

class DineSuccess extends DineState {}

class DineError extends DineState {
  final String message;
  DineError(this.message);
}