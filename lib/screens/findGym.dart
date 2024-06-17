import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:math' show cos, sqrt, asin;

class FindGymScreen extends StatefulWidget {
  const FindGymScreen({Key? key}) : super(key: key);
  @override
  _FindGymScreenState createState() => _FindGymScreenState();
}

class _FindGymScreenState extends State<FindGymScreen> {
  List<Map<String, dynamic>> _locations = [];
  List<Map<String, dynamic>> _FindGym = [];
  LocationPermission permission = LocationPermission.denied;
  String denied = '';

  @override
  void initState() {
    super.initState();
    _fetchAndComputeFindGym();
  }

  Future<void> _getLocationPermission() async {
    bool serviceEnabled;
    

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        ;
      });
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          denied = 'Location permissions are denied';
        });
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        denied = 'Location permissions are permanently denied, we cannot request permissions.';
      });
    }
  }

  Future<void> _fetchAndComputeFindGym() async {
    // Fetch locations from API
    final String apiUrl = '${dotenv.env['API_URL']!}/getGyms'; 
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final List<Map<String, dynamic>> locations = List<Map<String, dynamic>>.from(data);
      print('Locations: $locations');

      // Get current location
      await _getLocationPermission();
      double _calculateDistance(
        double lat1, double lon1, double lat2, double lon2) {
          const p = 0.017453292519943295; // Pi/180
          final a = 0.5 -
              cos((lat2 - lat1) * p) / 2 +
              cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
              return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
          };
      // if (permission == LocationPermission.deniedForever) {
      //   _FindGym=[{'Address': 'Could not get location', 'distance': denied}];
        
      // }else if (permission == LocationPermission.denied) {
        
      //   
      // }
      // else 
      print('Permission: $permission');
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        double currentLat = position.latitude;
        double currentLon = position.longitude;
        print('Current location: $currentLat, $currentLon');

        // Calculate distances
        for (var location in locations) {
          print('Location: $location');
          double distance = _calculateDistance(
            currentLat,
            currentLon,
            location['Latitude'],
            location['Longitude'],
          );
          location['distance'] = distance;
          
        }
        print('GRRR $locations');

        // Sort by distance and get top 3
        locations.sort((a, b) => a['distance'].compareTo(b['distance']));
        setState(() {
          _locations = locations;
          _FindGym = locations.take(3).toList();
        });
      } else {
        _FindGym=[{'Address': 'Could not get location. Check Permissions', 'distance': 0.0}];
      }
    };
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Closest Locations')),
      body: _FindGym.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _FindGym.length,
              itemBuilder: (context, index) {
                final location = _FindGym[index];
                return ListTile(
                  title: Text(location['Address']),
                  subtitle: Text('Distance: ${location['distance'].toStringAsFixed(2)} km'),
                );
              },
            ),
    );
  }
}
