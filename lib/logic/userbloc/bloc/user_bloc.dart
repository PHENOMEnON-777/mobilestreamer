import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fingerprint/data/provider/repository/userrepository.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  Userrepository userrepository;
  UserBloc({required this.userrepository}) : super(UserInitial()) {
    on<GetStationServicesbyId>((event, emit)async {
      emit(GetingStationServicesbyId());
      try {
        final response = await userrepository.stationServicesbuId(event.id);
        emit(GetingStationServicesbyIdSuccessfully(successfullMessage: response['msg'], data: response['data']));
      } catch (e) {
        emit(GetingStationServicesbyIdFailed(errorMessage: e.toString()));
      }
    });

    on<GetStationServices>((event, emit)async {
      emit(GetingStationServices());
      try {
        final response = await userrepository.getallstations();
        emit(GetingStationServicesSuccessfully(successfullMessage: response['msg'], data: response['data']));
      } catch (e) {
        emit(GetingStationServicesFailed(errorMessage: e.toString()));
      }
    });

     on<GetAllCompanies>((event, emit)async {
      emit(GetingAllCompanies());
      try {
        final response = await userrepository.getallcompanies();
        emit(GetingAllCompaniesSuccessful(successfullMessage: response['msg'], data: response['data']));
      } catch (e) {
        emit(GetingAllCompaniesFailed(errorMessage: e.toString()));
      }
    });

      on<GetTankByStationId>((event, emit) async {
      emit(GettingTankByStationId());
      try {
        final response = await userrepository.getTankbyStationId(event.id);
        emit(GettingTankByStationIdSuccessful(tanks: response['data'], successfullMessage: response['msg']));
      } catch (e) {
        emit(GettingTankByStationIdFailed(errormessage: e.toString()));
      }
    });
  }
}
