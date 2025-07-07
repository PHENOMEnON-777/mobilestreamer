


import 'package:fingerprint/data/provider/server/userservercervice.dart';

class Userrepository {

final  Userserverservices userserverservices;

const Userrepository({required this.userserverservices});

Future<Map<String,dynamic>> stationServicesbuId(String id) async {
  try {
    final response = await userserverservices.stationServicesbuId(id);
    return 
    {
      "data":response['data'],
      "success":response['success'],
      "msg":response['msg']
    };
  
    } catch (e) {
      rethrow;
    }
}

Future<Map<String,dynamic>> getallcompanies() async {
  try {
    final response = await userserverservices.getallcompanies() ;
    return 
    {
      "data":response['data'],
      "success":response['success'],
      "msg":response['msg']
    };
  
    } catch (e) {
      rethrow;
    }
}

Future<Map<String,dynamic>> getallstations() async {
  try {
    
    final response = await userserverservices.getallstaions() ;
    return 
    {
      "data":response['data'],
      "success":response['success'],
      "msg":response['msg']
    };
    } catch (e) {
      rethrow;
    }
}

Future<Map<String,dynamic>> getTankbyStationId(String id)async {
    final resposne = await userserverservices.getTankbyStationId(id);
    try {
      return {
        "data": resposne['data'],
        "msg": resposne['msg'],
        "success": resposne['success']
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String,dynamic>> getallnotifications() async {
  try {
    final response = await userserverservices.getallnotifications();
    return 
    {
      "data":response['data'],
      "success":response['success'],
      "msg":response['msg']
    };
  
    } catch (e) {
      rethrow;
    }
}

}