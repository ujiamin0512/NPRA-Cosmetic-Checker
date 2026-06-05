import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:assignment_2/models/location_data.dart';

class MapPickerPage extends StatefulWidget {
  // Accept initial location data if editing existing entry
  final LocationData? initialLocation;
  
  const MapPickerPage({super.key, this.initialLocation});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  late LatLng _markerLocation;
  late String _selectedPlaceName;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize with provided location or default to Kuala Lumpur
    if (widget.initialLocation != null) {
      _markerLocation = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
      _selectedPlaceName = widget.initialLocation!.placeName;
      // Pre-fill the search bar with the saved place name
      _searchController.text = widget.initialLocation!.placeName;
    } else {
      _markerLocation = const LatLng(3.140853, 101.693207);
      _selectedPlaceName = 'Search a place or tap the map...';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Move the map to the initial location after the first frame
    if (!_isInitialized && widget.initialLocation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(_markerLocation, 15.0);
          _isInitialized = true;
        }
      });
    }
  }

  // Helper function to extract a fallback name when the user taps (not searches)
  String _extractFallbackPlaceName(Placemark place) {
    // Prioritize the specific 'name' (if it's not just a number)
    if (place.name != null && 
        place.name!.trim().isNotEmpty && 
        !place.name!.contains(RegExp(r'^\d+$'))) {
      return place.name!;
    }
    // Fallback to street or locality
    if (place.street != null && place.street!.trim().isNotEmpty) {
      return place.street!;
    }
    return place.locality ?? 'Selected Location';
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus(); 
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final Location topResult = locations.first;
        final LatLng newCenter =
            LatLng(topResult.latitude, topResult.longitude);

        setState(() {
          _markerLocation = newCenter;
          _selectedPlaceName = query; 
        });
        
        _mapController.move(newCenter, 15.0);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location not found.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching location: $e')),
        );
      }
    }
  }

  Future<void> _reverseGeocode(LatLng latlng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          latlng.latitude, latlng.longitude);
      
      if (placemarks.isNotEmpty) {
        final String name = _extractFallbackPlaceName(placemarks.first);

        setState(() {
          _selectedPlaceName = name;
          _searchController.text = name;
        });
      }
    } catch (e) {
       // Reverse geocoding failed, retain current name
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only fetch placemark if we don't have a selected place name yet
    if (_selectedPlaceName == 'Search a place or tap the map...') {
      placemarkFromCoordinates(_markerLocation.latitude, _markerLocation.longitude)
          .then((p) {
              if (p.isNotEmpty && mounted && _selectedPlaceName == 'Search a place or tap the map...') {
                  setState(() {
                     _selectedPlaceName = _extractFallbackPlaceName(p.first);
                  });
              }
          }).catchError((_) {});
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Purchase Location'),
        backgroundColor: const Color(0xFF1D0CC2),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // The Map Widget (Flutter Map)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _markerLocation,
              initialZoom: 15.0,
              onTap: (tapPosition, latlng) {
                setState(() {
                  _markerLocation = latlng;
                });
                _reverseGeocode(latlng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'NPRA Cosmetic Checker',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: _markerLocation,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40.0,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Search Bar at the top
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search shop/place name (e.g., Watson Kota Warisan)',
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => _searchLocation(_searchController.text),
                    ),
                  ),
                  onSubmitted: _searchLocation,
                ),
              ),
            ),
          ),

          // Confirmation and Display Box at the bottom
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: FutureBuilder<List<Placemark>>(
              future: placemarkFromCoordinates(_markerLocation.latitude, _markerLocation.longitude),
              builder: (context, snapshot) {
                String currentAddress = 'Loading address...';
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final Placemark place = snapshot.data!.first;
                    currentAddress = [
                        place.street,
                        place.subLocality,
                        place.locality,
                        place.country,
                    ].where((s) => s != null && s.isNotEmpty).join(', ');
                } else if (snapshot.hasError) {
                    currentAddress = 'Error fetching address details.';
                }
                
                return Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // Display the name that will be saved
                          'Shop Name (Saved):',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedPlaceName,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Divider(height: 16),
                        Text(
                          'Pinned Address:',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          currentAddress, // Show the detailed address for confirmation
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1D0CC2),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              // Return LocationData object with name and coordinates
                              Navigator.of(context).pop(
                                LocationData(
                                  placeName: _selectedPlaceName,
                                  latitude: _markerLocation.latitude,
                                  longitude: _markerLocation.longitude,
                                )
                              );
                            },
                            child: const Text('Confirm Location'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}