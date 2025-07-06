import 'package:fingerprint/logic/userbloc/bloc/user_bloc.dart';
import 'package:fingerprint/presentation/widgets/animationonmap.dart';
import 'package:fingerprint/presentation/widgets/showstationdetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  String userId = '';
  late MapController _mapController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _showCharts = true;
  bool _isSatelliteMode = false;
  bool _showHeatmap = false;
  final double _currentZoom = 7.0;
  LatLng? _initialCenter;
  static const LatLng _defaultCenter = LatLng(51.5074, -0.1278);

  @override
  void initState() {
    super.initState();
    BlocProvider.of<UserBloc>(context).add(GetStationServices());
    _mapController = MapController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  List<CircleMarker> _buildPulsingCircles(List<dynamic> stations) {
    return stations
        .map((station) {
          final locationParts = (station['location'] as String).split(',');
          if (locationParts.length != 2) return null;

          final lat = double.tryParse(locationParts[0]);
          final lng = double.tryParse(locationParts[1]);
          if (lat == null || lng == null) return null;

          return CircleMarker(
            point: LatLng(lat, lng),
            radius: _showHeatmap ? 80 : 50,
            color:
                _showHeatmap
                    ? Colors.orange.withOpacity(0.2)
                    : Colors.blue.withOpacity(0.1),
            borderColor: _showHeatmap ? Colors.orange : Colors.blue,
            borderStrokeWidth: 1,
            useRadiusInMeter: false,
          );
        })
        .whereType<CircleMarker>()
        .toList();
  }

  List<Marker> _buildStationMarkers(List<dynamic> stations) {
    return stations
        .map((station) {
          final locationParts = (station['location'] as String).split(',');
          if (locationParts.length != 2) return null;

          final lat = double.tryParse(locationParts[0]);
          final lng = double.tryParse(locationParts[1]);
          if (lat == null || lng == null) return null;

          return Marker(
            point: LatLng(lat, lng),
            width: 80,
            height: 80,
            child: AnimatedStationMarker(
              station: station,
              onTap: () => showStationDetail(station, context),
            ),
          );
        })
        .whereType<Marker>()
        .toList();
  }

  LatLng _calculateCenterFromMarkers(List<Marker> markers) {
    if (markers.isEmpty) return _defaultCenter;

    double totalLat = 0;
    double totalLng = 0;

    for (final marker in markers) {
      totalLat += marker.point.latitude;
      totalLng += marker.point.longitude;
    }

    return LatLng(totalLat / markers.length, totalLng / markers.length);
  }

  Widget _buildMapControls() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        children: [
          FloatingActionButton.small(
            onPressed: () {
              setState(() {
                _showHeatmap = !_showHeatmap;
              });
            },
            backgroundColor:
                _showHeatmap
                    ? Colors.orange
                    : const Color.fromARGB(255, 16, 36, 53),
            heroTag: 'heatmap',
            child: Icon(Icons.heat_pump, size: 20),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            onPressed: () {
              setState(() {
                _isSatelliteMode = !_isSatelliteMode;
              });
            },
            backgroundColor:
                _isSatelliteMode
                    ? Colors.blue
                    : const Color.fromARGB(255, 16, 36, 53),
            heroTag: 'satellite',
            child: Icon(
              _isSatelliteMode ? Icons.map : Icons.satellite_alt_outlined,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapAndCalendarSection(List<dynamic> stations) {
    final markers = _buildStationMarkers(stations);
    final circles = _buildPulsingCircles(stations);
    final centerPoint =
        markers.isNotEmpty
            ? _calculateCenterFromMarkers(markers)
            : _defaultCenter;

    if (_initialCenter == null && centerPoint != _defaultCenter) {
      _initialCenter = centerPoint;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(centerPoint, _currentZoom);
        }
      });
    }

    return Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _initialCenter ?? _defaultCenter,
                            initialZoom: _currentZoom,
                            cameraConstraint: CameraConstraint.contain(
                              bounds: LatLngBounds(
                                const LatLng(-85, -180),
                                const LatLng(85, 180),
                              ),
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  _isSatelliteMode
                                      ? 'http://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}'
                                      : 'http://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                              subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                              maxZoom: 20,
                            ),
                            if (circles.isNotEmpty)
                              CircleLayer(circles: circles),
                            if (markers.isNotEmpty)
                              MarkerLayer(markers: markers),
                          ],
                        ),
                        _buildMapControls(),
                      ],
                    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      buildWhen: (previous, current) => current is GetingStationServicesSuccessfully,
      builder: (context, state) {
        if(state is GetingStationServices){
          return Center(child: CircularProgressIndicator(),);
        }
        if(state is GetingStationServicesSuccessfully){
          return _buildMapAndCalendarSection(state.data);
        }
        return Scaffold(
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _initialCenter ?? _defaultCenter,
                  initialZoom: _currentZoom,
                  cameraConstraint: CameraConstraint.contain(
                    bounds: LatLngBounds(
                      const LatLng(-85, -180),
                      const LatLng(85, 180),
                    ),
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        _isSatelliteMode
                            ? 'http://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}'
                            : 'http://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                    subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                    maxZoom: 20,
                  ),
                ],
              ),
              // _buildMapControls(),
            ],
          ),
        );
      },
    );
  }
}
