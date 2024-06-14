import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _response = '';
  final TextEditingController _controller = TextEditingController();
  String _location = 'Unknown location';

  Future<void> fetchData() async {
    const url = 'http://192.168.1.3:3000/api/getExercises'; // Use your deployed URL here
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          _response = response.body;
        });
      } else {
        setState(() {
          _response = 'Failed to fetch data';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    }
  }

  Future<void> sendComment(String exercise) async {
    const url = 'http://192.168.1.3:3000/api/createExercise'; // Use your deployed URL here
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': exercise,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _response = jsonDecode(response.body)['message'];
        });
      } else {
        setState(() {
          _response = 'Failed to add exercise';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _location = 'Location services are disabled.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _location = 'Location permissions are denied';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _location = 'Location permissions are permanently denied, we cannot request permissions.';
      });
      return;
    } 

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _location = 'Lat: ${position.latitude}, Lon: ${position.longitude}';
    });
  }

  void _openDisplayScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Next.js API Example'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: fetchData,
                child: const Text('Fetch All Exercises'),
              ),
              const SizedBox(height: 20),
              Text('Response: $_response'),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter Exercise Name',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  sendComment(_controller.text);
                },
                child: const Text('Add Exercise'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _openDisplayScreen,
                child: const Text('Open Display Screen'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getCurrentLocation,
                child: const Text('Get Current Location'),
              ),
              const SizedBox(height: 20),
              Text('Location: $_location'),
            ],
          ),
        ),
      ),
    );
  }
}
