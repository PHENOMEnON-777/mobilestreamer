


import 'dart:convert';

import 'package:http/http.dart' as http;

class Userserverservices {

    final url= 'https://streamer-production.up.railway.app';

    Future<Map<String,dynamic>> stationServicesbuId(String id,)async {
    final response = await http.get(Uri.parse("$url/allStationServicesbyIdformobile/$id"),
    headers: {
            'Content-Type': 'application/json',
            'Accept':'application/json',
    },
    );
  
    final responseData = jsonDecode(response.body) as Map<String,dynamic>;

try {
   if(responseData['success'] == true){
    return Map<String,dynamic>.from(jsonDecode(response.body));
    }
    else{
      final responseMessage =responseData['msg'];
      throw Exception(responseMessage);
    }
} catch (e) {
   final responseMessage =responseData['msg'];
      throw Exception(responseMessage);
}
  }
 Future<Map<String,dynamic>> getallcompanies()async {
    final response = await http.get(Uri.parse("$url/getallUsersformobile"),
    headers: {
            'Content-Type': 'application/json',
            'Accept':'application/json',
    },
    );
    final responseData = jsonDecode(response.body) as Map<String,dynamic>;
try {
   if(responseData['success'] == true){
    return Map<String,dynamic>.from(jsonDecode(response.body));
    }
    else{
      final responseMessage =responseData['msg'];
      throw Exception(responseMessage);
    }
} catch (e) {
   final responseMessage =responseData['msg'];
      throw Exception(responseMessage);
}
  }

   Future<Map<String,dynamic>> getallstaions()async {
    final response = await http.get(Uri.parse("$url/allStationServicesformobile"),
    headers: {
            'Content-Type': 'application/json',
            'Accept':'application/json',
    },
    );
    final responseData = jsonDecode(response.body) as Map<String,dynamic>;
try {
   if(responseData['success'] == true){
    return Map<String,dynamic>.from(jsonDecode(response.body));
    }
    else{
      final responseMessage =responseData['msg'];
      throw Exception(responseMessage);
    }
} catch (e) {
   final responseMessage =responseData['msg'];
      throw Exception(responseMessage);
}
  }

    Future<Map<String,dynamic>> getTankbyStationId(String id)async{
    final response = await http.get(Uri.parse("$url/tanks/gettankbystationIdformobile/$id"),
     headers: {
            'Content-Type': 'application/json',
            'Accept':'application/json',
    },);
    final responseData = jsonDecode(response.body) as Map<String,dynamic>;
    try {
      if(responseData['success'] == true){
        return Map<String,dynamic>.from(jsonDecode(response.body));
      }
      else{
        final responseMessage = responseData['msg'];
        throw Exception(responseMessage);
      }
    } catch (e) {
      final responseMessage = responseData['msg'];
        throw Exception(responseMessage);
    }
  }

   Future<Map<String,dynamic>> getallnotifications()async {
    final response = await http.get(Uri.parse("$url/getallnotifications"),
    headers: {
            'Content-Type': 'application/json',
            'Accept':'application/json',
    },
    );
    final responseData = jsonDecode(response.body) as Map<String,dynamic>;
try {
   if(responseData['success'] == true){
    return Map<String,dynamic>.from(jsonDecode(response.body));
    }
    else{
      final responseMessage =responseData['msg'];
      throw Exception(responseMessage);
    }
} catch (e) {
   final responseMessage =responseData['msg'];
      throw Exception(responseMessage);
}
  }

}