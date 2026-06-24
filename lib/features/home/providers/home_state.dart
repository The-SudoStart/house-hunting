import '../../../models/house.dart';

sealed class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeSuccess extends HomeState {
  final List<House> houses;

  const HomeSuccess(this.houses);
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);
}