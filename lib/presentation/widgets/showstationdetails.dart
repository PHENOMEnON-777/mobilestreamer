import 'package:fingerprint/logic/userbloc/bloc/user_bloc.dart';
import 'package:fingerprint/presentation/widgets/costumeliquidindicator.dart'; // Make sure this path is correct
import 'package:fingerprint/router/routers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

class ShowStationDetailContent extends StatefulWidget {
  final dynamic station;

  const ShowStationDetailContent({super.key, required this.station});

  @override
  State<ShowStationDetailContent> createState() => _ShowStationDetailContentState();
}

class _ShowStationDetailContentState extends State<ShowStationDetailContent> {
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    // Dispatch the event to fetch tank data ONLY ONCE when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserBloc>().add(GetTankByStationId(id: widget.station['id']));
    });

    // Parse location coordinates once in initState
    if (widget.station['location'] != null && widget.station['location'].isNotEmpty) {
      final List<String> coords = widget.station['location'].split(',');
      if (coords.length == 2) {
        try {
          latitude = double.parse(coords[0].trim());
          longitude = double.parse(coords[1].trim());
        } catch (e) {
          debugPrint('Error parsing location coordinates for station ${widget.station['id']}: $e');
        }
      }
    }
  }

  // Helper function to determine color based on tank type
  Color _getTankColor(String? type, BuildContext context) {
    if (type == null) return Theme.of(context).colorScheme.onSurface; // Default color

    final lowerCaseType = type.toLowerCase();
    switch (lowerCaseType) {
      case 'petrol':
        return Colors.green;
      case 'super':
        return Colors.blue;
      case 'gasoil':
        return Colors.amber;
      default:
        return Theme.of(context).colorScheme.onSurface; // Fallback to theme's default text color
    }
  }

  // Helper function to create manual tank data
  List<Map<String, dynamic>> _createManualTankData() {
    return [
      {
        'id': 'super_${widget.station['id']}',
        'type': 'Super',
        'level': 75.5, 
      },
      {
        'id': 'gasoil_${widget.station['id']}',
        'type': 'Gasoil',
        'level': 60.0, 
      },
    ];
  }

  // Helper function to combine API data with manual data
  List<Map<String, dynamic>> _combineeTankData(List<dynamic> apiTanks) {
    List<Map<String, dynamic>> combinedTanks = [];
    
    // Add API tanks (convert to proper format)
    for (var tank in apiTanks) {
      combinedTanks.add({
        'id': tank['id'],
        'type': tank['type'],
        'level': tank['level'],
      });
    }
    
    // Add manual tanks
    combinedTanks.addAll(_createManualTankData());
    
    return combinedTanks;
  }

  @override
  Widget build(BuildContext context) {
    context.read<UserBloc>().add(GetTankByStationId(id: widget.station['id']));
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final Color subtitleColor = onSurfaceColor.withOpacity(0.7);
    final Color errorColor = Theme.of(context).colorScheme.error;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: MediaQuery.of(context).size.height * 0.70,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1), // Use theme color for background
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_gas_station_rounded,
                    size: 32,
                    color: primaryColor, // Use theme color for icon
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.station['stationservicename'] ?? 'Unknown Station',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: onSurfaceColor, // Use theme color
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Location: ${widget.station['location'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: subtitleColor, // Use theme color
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 30, thickness: 1),
            Text(
              widget.station['description'] ?? 'No description available.',
              style: TextStyle(fontSize: 16, color: onSurfaceColor), // Use theme color
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<UserBloc>().add(GetStationServices());
                  if (latitude != null && longitude != null) {
                    Navigator.of(context).pushNamed(
                      trackstationscreen,
                      arguments: LatLng(latitude!, longitude!),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Location data not available or invalid.'),
                        backgroundColor: errorColor, // Use theme error color
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.map_outlined, size: 24),
                label: const Text('View on Map'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tank Levels:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: onSurfaceColor, // Use theme color
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BlocBuilder<UserBloc, UserState>(
                buildWhen: (previousState, currentState) {
                  // Ensure you filter by the station ID if your Bloc manages multiple stations
                  // Otherwise, this condition might not be strictly necessary if only one station's tanks are fetched at a time.
                  final currentStationId = (currentState is GettingTankByStationId ) ||
                                           (currentState is GettingTankByStationIdSuccessful ) ||
                                           (currentState is GettingTankByStationIdFailed);
                  return currentStationId;
                },
                builder: (context, state) {
                  // Add a check for the correct state and station ID before accessing state properties
                  if (state is GettingTankByStationId ){
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  if (state is GettingTankByStationIdSuccessful ) {
                    // Combine API data with manual data
                    final List<Map<String, dynamic>> allTanks = _combineeTankData(state.tanks);
                    
                    if (allTanks.isEmpty) {
                      return Center(
                        child: Text(
                          'No tank data available for this station.',
                          style: TextStyle(fontStyle: FontStyle.italic, color: subtitleColor), // Use theme color
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      itemCount: allTanks.length,
                      physics: const ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final tankData = allTanks[index];
                        final tankColor = _getTankColor(tankData['type'], context); // Get the dynamic color
                        final tankLevel = (tankData['level'] as num?)?.toDouble() ?? 0.0; // Safely cast and default to 0.0
                        
                        // Check if this is a manual tank (not from API)
                        final isManualTank = tankData['id'].toString().startsWith('super_') || 
                                           tankData['id'].toString().startsWith('gasoil_');

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).cardColor, // Use card color from theme
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      tankData['type'] ?? 'Unknown Type',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19,
                                        color: tankColor, // Apply dynamic color
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'available',
                                      style: TextStyle(color: Colors.lightGreen),
                                    ),
                                    if (isManualTank)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Manual',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: screenWidth  * 0.2,
                                      height: screenHeight *  0.07,
                                      child: CustomLiquidIndicator(
                                        value: tankLevel / 100, 
                                        color: tankColor, 
                                        enableAnimation: true,
                                        waveDuration: const Duration(seconds: 4),
                                        customPath: GasBottlePath(),
                                        center: Text(
                                          "${tankLevel.toStringAsFixed(1)}%", // <--- Corrected: use tankLevel
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        stationId: tankData['id'],
                                        screenWidth: screenWidth * 0.1,
                                        tankType: tankData['type'], // Keep this as string
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Current Level: ${tankLevel.toStringAsFixed(2)} %', // <--- Corrected: use tankLevel
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: onSurfaceColor, // Level text can be a general color or tankColor
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  if (state is GettingTankByStationIdFailed) {
                    // Even if API fails, show manual data
                    final List<Map<String, dynamic>> manualTanks = _createManualTankData();
                    
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning, color: errorColor, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Failed to load API data: ${state.errormessage}',
                                  style: TextStyle(color: errorColor, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: manualTanks.length,
                            physics: const ClampingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final tankData = manualTanks[index];
                              final tankColor = _getTankColor(tankData['type'], context);
                              final tankLevel = (tankData['level'] as num?)?.toDouble() ?? 0.0;

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 6.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context).cardColor,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            tankData['type'] ?? 'Unknown Type',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 19,
                                              color: tankColor,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            'available',
                                            style: TextStyle(color: Colors.lightGreen),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Manual',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.orange,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: screenWidth  * 0.2,
                                            height: screenHeight *  0.07,
                                            child: CustomLiquidIndicator(
                                              value: tankLevel / 100, 
                                              color: tankColor, 
                                              enableAnimation: true,
                                              waveDuration: const Duration(seconds: 4),
                                              customPath: GasBottlePath(),
                                              center: Text(
                                                "${tankLevel.toStringAsFixed(1)}%",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              stationId: tankData['id'],
                                              screenWidth: screenWidth * 0.1,
                                              tankType: tankData['type'],
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            'Current Level: ${tankLevel.toStringAsFixed(2)} %',
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: onSurfaceColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showStationDetail(dynamic station, BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => ShowStationDetailContent(station: station),
  );
}