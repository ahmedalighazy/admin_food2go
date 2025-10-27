abstract class RestaurantState {}

class RestaurantInitial extends RestaurantState {}

class RestaurantLoading extends RestaurantState {}

class RestaurantSuccess extends RestaurantState {
  final String restaurantId;
  final String baseUrl;

  RestaurantSuccess({required this.restaurantId, required this.baseUrl});
}

class RestaurantError extends RestaurantState {
  final String message;

  RestaurantError(this.message);
}