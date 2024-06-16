import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:muscletracker/screens/loginPage.dart';
import 'package:muscletracker/screens/workout.dart';
import 'package:muscletracker/screens/newExercise.dart';
import 'package:muscletracker/screens/newWorkout.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'package:muscletracker/screens/stats.dart';
import 'package:muscletracker/screens/findGym.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MuscleTrackerApp(
        
      ),
    ),
  );
}

class MuscleTrackerApp extends StatelessWidget {
  const MuscleTrackerApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muscle Tracker',
      initialRoute: '/home',
      routes: {
        '/home': (context) => const MyHomePage(),
        '/login': (context) => const LoginPage(),
        '/Workouts': (context) => const WorkoutAccordion(),
        '/newExercise': (context) => const NewExerciseScreen(),
        '/newWorkouts': (context) => const WorkoutScreen(),
        '/stats': (context) => const StatsScreen(),
        '/findGym': (context) => const FindGymScreen(),
      },
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
    Navigator.pushNamed(
      context,
      '/login',
    );
  }

  @override
  Widget build(BuildContext context) {
    final String data = Provider.of<UserProvider>(context).user;
    // final String data = ModalRoute.of(context)!.settings.arguments as String? ?? 'No data received';
    print('Data: $data');
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: const Text('Muscle Tracker'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.publish_sharp),
              title: const Text('New Workout'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/newWorkouts');
              },
            ),
            ListTile(
              leading: const Icon(Icons.rowing_sharp),
              title: const Text('New Exercise'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/newExercise', arguments: data);
              },
            ),
            ListTile(
              leading: const Icon(Icons.monitor_weight),
              title: const Text('Stats'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/stats', arguments: data);
              },
            ),
            ListTile(
              leading: const Icon(Icons.publish_sharp),
              title: const Text('Workouts'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/Workouts');
              },
            ),
            ListTile(
              leading: const Icon(Icons.map_rounded),
              title: const Text('Find a Gym'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/findGym');
              },
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              
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
              Text('Data: $data'),
            ],
          ),
        ),
      ),
    );
  }
}
