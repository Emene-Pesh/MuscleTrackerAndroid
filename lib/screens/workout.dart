import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MaterialApp(
    home: WorkoutAccordion(),
  ));
}

class WorkoutAccordion extends StatefulWidget {
  const WorkoutAccordion({super.key});

  @override
  _WorkoutAccordionState createState() => _WorkoutAccordionState();
}


class _WorkoutAccordionState extends State<WorkoutAccordion> {
  List<Item> _data = [];

  @override
  void initState() {
    super.initState();
    fetchWorkouts();
  }
  Future<void> fetchWorkouts() async {
    final url = '${dotenv.env['API_URL']!}/getWorkouts'; // Replace with your API URL
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body) as List<dynamic>;
        final List<Workout> workouts = jsonData.map((json) => Workout.fromJson(json)).toList();
        setState(() {
          _data = workouts.map<Item>((Workout workout) {
            return Item(
              headerValue: '${workout.name} ${workout.date.toLocal()}'.split(' ')[0],
              expandedValue: workout,
              isExpanded: false,
            );
          }).toList();
        });
      } else {
        print('Failed to load workouts');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
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
                Navigator.pushNamed(context, '/newExercise');
              },
            ),
            ListTile(
              leading: const Icon(Icons.monitor_weight),
              title: const Text('Stats'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/stats');
              },
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('Workouts'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/workouts');
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
      body: SingleChildScrollView(
        child: ExpansionPanelList(
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              _data[index].isExpanded = !_data[index].isExpanded;
              print('Panel $index is ${_data[index].isExpanded ? "expanded" : "collapsed"}');
            });
          },
          children: _data.map<ExpansionPanel>((Item item) {
            return ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      item.isExpanded = !item.isExpanded;
                    });
                  },
                  child: ListTile(
                    title: Text(item.headerValue),
                  ),
                );
              },
              body: Column(
                children: item.expandedValue.exercises.map<Widget>((Exercise exercise) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Exercise: ${exercise.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: exercise.sets.map<Widget>((ExerciseSet set) {
                            return Text('Weight: ${set.weight}, Reps: ${set.repAmount}, RPE: ${set.RPE}');
                          }).toList(),
                        ),
                        const Divider(),
                      ],
                    ),
                  );
                }).toList(),
              ),
              isExpanded: item.isExpanded,
            );
          }).toList(),
        ),
      ),
    );
  }
}


class Workout {
  final String name;
  final DateTime date;
  final List<Exercise> exercises;

  Workout({
    required this.name,
    required this.date,
    required this.exercises,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      name: json['Name'] as String,
      date: DateTime.parse(json['date'] as String),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e))
          .toList(),
    );
  }
}

class Exercise {
  final String name;
  final List<ExerciseSet> sets;

  Exercise({
    required this.name,
    required this.sets,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] as String,
      sets: (json['sets'] as List<dynamic>)
          .map((s) => ExerciseSet.fromJson(s))
          .toList(),
    );
  }
}

class ExerciseSet {
  final int weight;
  final int repAmount;
  final int RPE;

  ExerciseSet({
    required this.weight,
    required this.repAmount,
    required this.RPE,
  });

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      weight: json['weight'] as int,
      repAmount: json['repAmount'] as int,
      RPE: json['RPE'] as int,
    );
  }
}

class Item {
  final String headerValue;
  final Workout expandedValue;
  bool isExpanded;

  Item({
    required this.headerValue,
    required this.expandedValue,
    this.isExpanded = false,
  });
}
