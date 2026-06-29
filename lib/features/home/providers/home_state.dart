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
  final String? notice;

  const HomeSuccess(this.houses, {this.notice});
}

class HomeError extends HomeState {
  final String message;
  final bool canRetry;

  const HomeError(this.message, {this.canRetry = true});
}
