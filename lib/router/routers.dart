import 'package:fingerprint/homapage.dart';
import 'package:fingerprint/presentation/screens/notificationscreen.dart';
import 'package:fingerprint/presentation/screens/trackstationservicescreen.dart';
import 'package:fingerprint/presentation/widgets/costumnavigationbar.dart';
import 'package:flutter/material.dart';
import 'package:fingerprint/presentation/screens/homescreen.dart';
import 'package:fingerprint/presentation/screens/mapscreen.dart';
import 'package:latlong2/latlong.dart';



const String authScreenRoute = '/'; 
const String homeTabsScreenRoute = '/home_tabs';
const String homeContentScreenRoute = '/home_content'; 
const String mapScreenRoute = '/map'; 
const String trackstationscreen = '/trackstationscreen';       
const String notificationsscreen = '/notificationsscreen';


class AppRoute {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case authScreenRoute:
        return MaterialPageRoute(builder: (context) => const AuthScreen());

      case homeTabsScreenRoute:

        return MaterialPageRoute(builder: (context) => const HomeTabsScreen());

      case trackstationscreen:
      final LatLng latlongData = settings.arguments as LatLng;
        return MaterialPageRoute(builder: (context) =>  TrackStationScreen(latlongdataofcoaw: latlongData));

      case homeContentScreenRoute:
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      case notificationsscreen:
      return MaterialPageRoute(builder: (context)=> const NotificationScreen()) ;

      case mapScreenRoute:
        return MaterialPageRoute(builder: (context) => const MapScreen());

      default:
        return MaterialPageRoute(
          builder: ((context) => Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text('Error: No route defined for ${settings.name}'),
            ),
          )),
        );
    }
  }
}