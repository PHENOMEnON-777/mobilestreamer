import 'dart:async';
import 'dart:convert';

import 'package:fingerprint/logic/userbloc/bloc/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

// import '../../logic/adminscreen/bloc/adminscreen_bloc.dart';

class TrackStationScreen extends StatefulWidget {
  final LatLng latlongdataofcoaw;

  const TrackStationScreen({super.key, required this.latlongdataofcoaw});

  @override
  State<TrackStationScreen> createState() => _TrackCoawScreenState();
}

class _TrackCoawScreenState extends State<TrackStationScreen> {
  bool issatalitemode= false;
  bool _isUserInteracting = false; // Track user interaction
  bool _isMapInitialized = false;
  bool _isMapInteractive = false;
  LatLng? _initialCenter;
  Location locationController = Location();
  List<LatLng> polylineCoordinates = []; // List to hold polyline coordinates
  StreamSubscription<LocationData>? locationSubscription;
  late MapController _mapController;
  // Cache for previously fetched routes
  final Map<String, List<LatLng>> _routeCache = {};
  Timer? _debounce;
  Timer? _interactionResetTimer;
  double _currentZoom = 13.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    getLocationUpdate();
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    _debounce?.cancel();
    _interactionResetTimer?.cancel();
    super.dispose();
  }

  Future<void> getLocationUpdate() async {
    bool serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    locationSubscription = locationController.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        final newCenter = LatLng(currentLocation.latitude!, currentLocation.longitude!);

        if (_initialCenter == null || _initialCenter != newCenter) {

            _initialCenter = newCenter;

        if (!_isUserInteracting && _isMapInitialized ) {
               _mapController.move(_initialCenter!, _currentZoom);

        }
          fetchRouteWithThrottle(widget.latlongdataofcoaw);
        }
      }
    });
  }

  void fetchRouteWithThrottle(LatLng destination) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      getPolylinePoints(destination);
    });
  }

  Future<void> getPolylinePoints(LatLng destination) async {
    if (_initialCenter == null) return;

    final cacheKey = "${_initialCenter!.longitude},${_initialCenter!.latitude};${destination.longitude},${destination.latitude}";
    if (_routeCache.containsKey(cacheKey)) {
      setState(() {
        polylineCoordinates = _routeCache[cacheKey]!; 
      });
      return;
    }

    final url ='http://router.project-osrm.org/route/v1/driving/${_initialCenter!.longitude},${_initialCenter!.latitude};${destination.longitude},${destination.latitude}?geometries=geojson&overview=full';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final points = (data['routes'][0]['geometry']['coordinates'] as List)
            .map((point) => LatLng(point[1], point[0]))
            .toList();

            if(mounted){
               setState(() {
          polylineCoordinates = points;
          _routeCache[cacheKey] = points;
        });
            }

       
      } else if (mounted){

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Connection problem,'),
              content: Text(response.reasonPhrase.toString()),
            );
          }
        );
      }
    } catch (e) {
      if(mounted){
         showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Connection problem,'),
            content: Text(e.toString()),
          );
        }
      );
      }
    }
  }

  void _resetUserInteraction() {
    _interactionResetTimer?.cancel();
    _interactionResetTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _isUserInteracting = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {


    //   final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<UserBloc, UserState>(
          buildWhen: (previous, current) => current is GetingStationServicesbyIdSuccessfully || current is GetingStationServicesSuccessfully,
          builder: (context, state) {
            if (state is GetingStationServicesbyIdSuccessfully || state is GetingStationServicesSuccessfully) {
              return _initialCenter == null
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2,))
                  : FlutterMap(
                    mapController: _mapController,
                      options: MapOptions(
                        onPositionChanged: (camera, hasGesture) {
                          if (hasGesture) {
                                  setState(() {
                                    _isUserInteracting = true;
                                    _currentZoom = camera.zoom;
                                  });
                                  _resetUserInteraction();
                                } else if (!_isMapInteractive) {
                                  setState(() {
                                    _currentZoom = camera.zoom;

                                  });
                                }
                                if (!_isMapInitialized) {
                                  setState(() {
                                    _isMapInitialized = true;
                                  });
                                }
                        },
                        initialCenter: _initialCenter!,
                        initialZoom: _currentZoom,
                         interactionOptions: InteractionOptions(
                          flags: _isMapInteractive ? InteractiveFlag.all : InteractiveFlag.none,
                        ),
                        onTap: (tapPosition, point) {
                          setState(() {
                            _isMapInteractive = !_isMapInteractive;
                          });
                        },
                      
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:issatalitemode ? 'http://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}' : 'http://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                          subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                          maxZoom: 20,
                        ),
                        CircleLayer(circles: [
                              CircleMarker(point:widget.latlongdataofcoaw,color: Colors.blue.withOpacity(0.3),
                                    borderStrokeWidth: 2,
                                    borderColor: Colors.blue, radius: 30)
                            ]),
                        MarkerLayer(
                          markers: [

                            Marker(
                              point: widget.latlongdataofcoaw,
                              child:  Icon(Icons.ev_station)),

                            Marker(
                              point: _initialCenter!,
                              child: const Icon(Icons.person_pin_rounded, size: 45, color: Colors.green),
                            ),
                          ],
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: polylineCoordinates,
                              strokeWidth: 5.0,
                              color: Colors.purple,
                            ),
                          ],
                        ),
                      ],
                    );
            }
            return const Center(child: CircularProgressIndicator(strokeWidth: 2,));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
        setState(() {
          issatalitemode=!issatalitemode;
        });
      },child:  Icon(Icons.satellite_alt_rounded,color: Theme.of(context).colorScheme.secondaryFixed,),),
    );
  }
}
