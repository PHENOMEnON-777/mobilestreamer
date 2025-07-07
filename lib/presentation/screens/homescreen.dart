import 'package:fingerprint/logic/themebloc/bloc/theme_bloc.dart';
import 'package:fingerprint/logic/userbloc/bloc/user_bloc.dart';
import 'package:fingerprint/presentation/widgets/notificationwidget.dart';
import 'package:fingerprint/router/routers.dart'; // Make sure this path is correct
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart'; // Make sure this import is present

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? expandedUserId;
  List<dynamic> _allUsers = []; 
  List<dynamic> _displayedUsers = []; 

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_performSearch);
    // Request initial data for all companies when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserBloc>().add(GetAllCompanies());
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_performSearch);
    _searchController.dispose();
    super.dispose();
  }

  // Filters _allUsers based on the search query and updates _displayedUsers
  void _performSearch() {
    setState(() {
      if (_searchController.text.isNotEmpty) {
        final searchQuery = _searchController.text.toLowerCase();
        _displayedUsers = _allUsers.where((user) {
          final userName = user['name']?.toString().toLowerCase() ?? '';
          final userEmail = user['email']?.toString().toLowerCase() ?? '';
          return userName.contains(searchQuery) || userEmail.contains(searchQuery);
        }).toList();
      } else {
        _displayedUsers = List.from(_allUsers); // Reset to all users if search is empty
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          
          // Handle successful data fetching for all companies
          if (state is GetingAllCompaniesSuccessful) {
            setState(() {
              _allUsers = state.data;
              // Re-apply search filter if there's text in the search bar
              if (_searchController.text.isNotEmpty) {
                _performSearch();
              } else {
                _displayedUsers = List.from(_allUsers); // Otherwise, show all users
              }
            });
          }
          // Show SnackBars for failures
          if (state is GetingAllCompaniesFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load companies: ${state.errorMessage}',),
              ),
            );
          }
          if (state is GetingStationServicesbyIdFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load station services: ${state.errorMessage}',),
              ),
            );
          }
        },
        child: Column(
          children: [
            // --- Header with Search Bar ---
            Container(
              padding: const EdgeInsets.fromLTRB(24.0, 50.0, 24.0, 20.0), // More specific padding
              decoration: BoxDecoration(
                    color:Colors.deepPurple,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                // boxShadow: [
                //   BoxShadow(
                //     color: Theme.of(context).secondaryHeaderColor,
                //     blurRadius: 15,
                //     offset: const Offset(0, 8),
                //   ),
                // ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Companies',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 50.0),
                        child: NotificationWidget(),
                      ),
                      IconButton(onPressed: (){
                        context.read<ThemeBloc>().add(ChangeAppMode());
                      }, icon: Icon(Icons.dark_mode))
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or email...',
                      prefixIcon: const Icon(Icons.search,),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _performSearch();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    ),
                    style: const TextStyle( fontSize: 16),
                  ),
                ],
              ),
            ),
            // --- User List Content ---
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                // Show loading indicator
                if (state is GetingAllCompanies) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2,)),
                  );
                }

                // Show "No users found" message for empty lists
                if (_displayedUsers.isEmpty &&
                    (state is GetingAllCompaniesSuccessful || state is UserInitial)) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        _searchController.text.isNotEmpty
                            ? 'No matching users found.'
                            : 'No users available. Pull down to refresh.',
                        style: TextStyle(fontSize: 16, ),
                      ),
                    ),
                  );
                }

                // Display the list of users
                return Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<UserBloc>().add(GetAllCompanies());
                    },
                    child: ListView.builder(
                      itemCount: _displayedUsers.length,
                      itemBuilder: (context, index) {
                        final userData = _displayedUsers[index];
                        final role = userData['role'];
                        final name = userData['name'];
                        final userId = userData['id'];

                        return Card(
                          color: Theme.of(context).secondaryHeaderColor,
                          margin: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  child: Icon(Icons.business, ),
                                ),
                                title: Text(
                                  "$name - $role",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                subtitle: Text(
                                  userData['email'] ?? 'No email',
                                  style: TextStyle(color: Colors.green),
                                    overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    expandedUserId == userId
                                        ? Icons.expand_less_rounded
                                        : Icons.expand_more_rounded,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      // Toggle expanded state
                                      expandedUserId = expandedUserId == userId ? null : userId;
                                      // Fetch station services if expanding
                                      if (expandedUserId == userId) {
                                        context.read<UserBloc>().add(
                                              GetStationServicesbyId(id: userId),
                                            );
                                      }
                                    });
                                  },
                                ),
                              ),
                              // Animated section for station services
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: expandedUserId == userId
                                    ? BlocBuilder<UserBloc, UserState>(
                                        // This BlocBuilder only rebuilds when UserState changes
                                        // and is relevant to the currently expanded user's services.
                                        buildWhen: (previousState, currentState) {
                                          return (currentState is GetingStationServicesbyId ) ||
                                                 (currentState is GetingStationServicesbyIdSuccessfully ) ||
                                                 (currentState is GetingStationServicesbyIdFailed );
                                        },
                                        builder: (context, state) {
                                          // Loading state for specific user's services
                                          if (state is GetingStationServicesbyId ) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                                              child: CircularProgressIndicator(strokeWidth: 2,),
                                            );
                                          }
                                          // Successful fetch, display services
                                          if (state is GetingStationServicesbyIdSuccessfully ) {
                                            if (state.data.isEmpty) {
                                              return Padding(
                                                padding: const EdgeInsets.all(16.0),
                                                child: Text(
                                                  'No station services found for this company.',
                                                  style: TextStyle(fontStyle: FontStyle.italic,),
                                                  textAlign: TextAlign.center,
                                                ),
                                              );
                                            }
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                                                  child: Text(
                                                    'Station Services:',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                ),
                                                ListView.builder(
                                                  physics: const NeverScrollableScrollPhysics(), // Prevent inner scroll
                                                  shrinkWrap: true, // Take only needed space
                                                  itemCount: state.data.length,
                                                  itemBuilder: (context, serviceIndex) {
                                                    final station = state.data[serviceIndex];
                                                    double? latitude;
                                                    double? longitude;
                                                    if (station['location'] != null && station['location'].isNotEmpty) {
                                                      final List<String> coords = station['location'].split(',');
                                                      if (coords.length == 2) {
                                                        try {
                                                          latitude = double.parse(coords[0].trim());
                                                          longitude = double.parse(coords[1].trim());
                                                        } catch (e) {
                                                          debugPrint('Error parsing location coordinates: $e');
                                                        }
                                                      }
                                                    }

                                                    return 
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                                    
                                                        child: ListTile(
                                                          tileColor: Colors.blueGrey[700], // Original color
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                          leading: Icon(Icons.local_gas_station,),
                                                          title: Text(
                                                            station['stationservicename'] ?? 'Unnamed Station',
                                                            style: TextStyle( fontWeight: FontWeight.w600),
                                                          ),
                                                          subtitle: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                station['description'] ?? 'No description',
                                                                style: TextStyle( fontSize: 13),
                                                              ),
                                                              if (station['location'] != null && station['location'].isNotEmpty)
                                                                Text(
                                                                  'Coords: ${station['location']}',
                                                                  style: TextStyle( fontSize: 12),
                                                                ),
                                                            ],
                                                          ),
                                                          trailing: IconButton(
                                                            onPressed: () {
                                                              if (latitude != null && longitude != null) {
                                                                Navigator.of(context).pushNamed(
                                                                  trackstationscreen, 
                                                                  arguments: LatLng(latitude, longitude),
                                                                );
                                                              } else {
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  const SnackBar(content: Text('Location data not available or invalid for this station.')),
                                                                );
                                                              }
                                                            },
                                                            icon: Icon(Icons.map_outlined, color:Colors.amber ,),
                                                          ),
                                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                                        ),
                                                    );
                                                  },
                                                ),
                                                const SizedBox(height: 12.0),
                                              ],
                                            );
                                          }
                                          // Failed to fetch services for specific user
                                          if (state is GetingStationServicesbyIdFailed ) {
                                            return Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Text(
                                                'Failed to load services: ${state.errorMessage}',
                                                style: TextStyle( fontStyle: FontStyle.italic),
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          }
                                          // Default case for the inner BlocBuilder (e.g., when other users' services are being fetched)
                                          return const SizedBox.shrink();
                                        },
                                      )
                                    : const SizedBox.shrink(), // Hidden when not expanded
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}