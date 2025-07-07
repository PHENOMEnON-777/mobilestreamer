part of 'user_bloc.dart';

sealed class UserState extends Equatable {
  const UserState();
  
  @override
  List<Object> get props => [];
}

final class UserInitial extends UserState {}

final class GetingStationServicesbyId extends UserState {}

final class GetingStationServicesbyIdSuccessfully extends UserState {
  final String successfullMessage;
  final List<dynamic> data;

  const GetingStationServicesbyIdSuccessfully({required this.successfullMessage,required this.data});

  @override
  List<Object> get props => [successfullMessage,data];
}

final class GetingStationServicesbyIdFailed extends UserState {
  final String errorMessage;

  const GetingStationServicesbyIdFailed({required this.errorMessage,});

  @override
  List<Object> get props => [errorMessage,];
}

final class GetingStationServices extends UserState {}

final class GetingStationServicesSuccessfully extends UserState {
  final String successfullMessage;
  final List<dynamic> data;

  const GetingStationServicesSuccessfully({required this.successfullMessage,required this.data});

  @override
  List<Object> get props => [successfullMessage,data];
}

final class GetingStationServicesFailed extends UserState {
  final String errorMessage;

  const GetingStationServicesFailed({required this.errorMessage,});

  @override
  List<Object> get props => [errorMessage,];
}


final class GetingAllCompanies extends UserState {}

final class GetingAllCompaniesSuccessful extends UserState {
  final String successfullMessage;
  final List<dynamic> data;

  const GetingAllCompaniesSuccessful({required this.successfullMessage,required this.data});

  @override
  List<Object> get props => [successfullMessage,data];
}

final class GetingAllCompaniesFailed extends UserState {
  final String errorMessage;

  const GetingAllCompaniesFailed({required this.errorMessage,});

  @override
  List<Object> get props => [errorMessage,];
}


final class GettingTankByStationId extends UserState {}

final class GettingTankByStationIdSuccessful extends UserState {
  final String successfullMessage;
  final List<dynamic> tanks;

  const GettingTankByStationIdSuccessful({required this.tanks, required this.successfullMessage});

  @override
  List<Object> get props => [tanks,successfullMessage];
}

final class GettingTankByStationIdFailed extends UserState {
  final String errormessage;

  const GettingTankByStationIdFailed({required this.errormessage});

  @override
  List<Object> get props => [errormessage];
}



final class GetingAllNotifications extends UserState {}

final class GetingAllNotificationsSuccessfully extends UserState {
  final String successfullMessage;
  final List<dynamic> data;

  const GetingAllNotificationsSuccessfully({required this.successfullMessage,required this.data});

  @override
  List<Object> get props => [successfullMessage,data];
}

final class GetingAllNotificationsFailed extends UserState {
  final String errorMessage;

  const GetingAllNotificationsFailed({required this.errorMessage,});

  @override
  List<Object> get props => [errorMessage,];
}
