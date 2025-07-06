part of 'user_bloc.dart';

sealed class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}


final class GetStationServicesbyId extends UserEvent {
  final String id;
  const GetStationServicesbyId({required this.id});

  @override
  List<Object> get props => [id];
}
final class GetStationServices extends UserEvent {}

final class GetAllCompanies extends UserEvent {}

final class GetTankByStationId extends UserEvent{
  final String id;
  const GetTankByStationId({required this.id});

    @override
  List<Object> get props => [id];
}