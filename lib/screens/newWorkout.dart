import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';




class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({Key? key}) : super(key: key);
  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  List<Exercise> exercises = [];
  final TextEditingController _workoutNameController = TextEditingController();
  DateTime _currentDate = DateTime.now(); // Added date field
  List<String> exerciseNames = [];

  @override
  void initState() {
    super.initState();
    fetchExerciseNames();
    
  }

  Future<void> fetchExerciseNames() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.56.1:3000/api/getExercises'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        Set<dynamic> uniqueExerciseNames = data.map((exercise) => exercise['name'].toString()).toSet();
        print('Unique Exercise Names: $uniqueExerciseNames');
        setState(() {
          exerciseNames = uniqueExerciseNames.map((e) => e.toString()).toList();
        });
        print('Exercise Names: $exerciseNames');
      } else {
        print('Failed to load exercise names. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading exercise names: $e');
    }
  }

  void submitWorkout() async {
    String workoutName = _workoutNameController.text;
    List<Map<String, dynamic>> exercisesJson = exercises.map((exercise) => exercise.toJson()).toList();
    

    Map<String, dynamic> workoutData = {
      'title': workoutName,
      'date': _currentDate.toUtc().toIso8601String(),
      'exercise': {
        'create': exercisesJson,
      },
    };

    String jsonBody = json.encode(workoutData);
    print('Workout Data: $workoutData');

    try {
      final response = await http.post(
        Uri.parse('http://192.168.56.1:3000/api/newWorkout'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        print('Workout submitted successfully!');
      } else {
        print('Failed to submit workout. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting workout: $e');
    }
  }

  void addExercise() {
    setState(() {
      exercises.add(Exercise(name: ' ', sets: []));
    });
  }

  void removeExercise(int index) {
    setState(() {
      exercises.removeAt(index);
    });
  }

  void updateExercise(int index, Exercise exercise) {
    setState(() {
      exercises[index] = exercise;
    });
  }

  void addSet(int exerciseIndex) {
    setState(() {
      exercises[exerciseIndex].sets.add(Sets(weight: 0, repAmount: 0, RPE: 0));
    });
  }
  void removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      exercises[exerciseIndex].sets.removeAt(setIndex);
    });
  }

  void updateSet(int exerciseIndex, int setIndex, Sets set) {
    setState(() {
      exercises[exerciseIndex].sets[setIndex] = set;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Workout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
            controller: _workoutNameController,
            decoration: InputDecoration(labelText: 'Workout Name'),
          ),
          ElevatedButton(
            onPressed: submitWorkout,
            child: Text('Submit Workout'),
          ),
            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  print(index);
                  return 
                  ExerciseInput(
                    exercise: exercises[index],
                    onRemove: () => removeExercise(index),
                    onUpdate: (updatedExercise) => updateExercise(index, updatedExercise),
                    onAddSet: () => addSet(index),
                    onUpdateSet: (setIndex, updatedSet) => updateSet(index, setIndex, updatedSet),
                    onRemoveSet: (setIndex) => removeSet(index, setIndex),
                    exerciseNames: exerciseNames,
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: addExercise,
              child: Text('Add Exercise'),
            ),
            ElevatedButton(
            onPressed: submitWorkout,
            child: Text('Submit Workout'),
          ),
          ],
        ),
      ),
    );
  }
}

class ExerciseInput extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onRemove;
  final ValueChanged<Exercise> onUpdate;
  final VoidCallback onAddSet;
  final Function(int, Sets) onUpdateSet;
  final Function(int) onRemoveSet;
  final List<String> exerciseNames;

  ExerciseInput({
    required this.exercise,
    required this.onRemove,
    required this.onUpdate,
    required this.onAddSet,
    required this.onUpdateSet,
    required this.onRemoveSet,
    required this.exerciseNames,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Exercise Name'),
              items: exerciseNames.map((String name) {
                return DropdownMenuItem<String>(
                  value: name,
                  child: Text(name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  exercise.name = value;
                  onUpdate(exercise);
                }
              },
            ),
            Column(
              children: List.generate(
                exercise.sets.length,
                (index) => SetInput(
                  set: exercise.sets[index],
                  onUpdate: (updatedSet) => onUpdateSet(index, updatedSet),
                  onRemove: () => onRemoveSet(index),
                ),
              ),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: onAddSet,
              child: Text('Add Set'),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: onRemove,
              child: Text('Remove Exercise'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}



class SetInput extends StatelessWidget {
  final Sets set;
  final ValueChanged<Sets> onUpdate;
  final VoidCallback onRemove;

  SetInput({
    required this.set,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(labelText: 'Weight'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            set.weight = int.tryParse(value) ?? 0;
            onUpdate(set);
          },
          controller: set.weightController,
        ),
        TextField(
          decoration: InputDecoration(labelText: 'Reps'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            set.repAmount = int.tryParse(value) ?? 0;
            onUpdate(set);
          },
          controller: set.repAmountController,
        ),
        TextField(
          decoration: InputDecoration(labelText: 'RPE'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            set.RPE = int.tryParse(value) ?? 0;
            onUpdate(set);
          },
          controller: set.RPEController,
        ),
        ElevatedButton(
          onPressed: onRemove,
          child: Text('Remove Set'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black54),
        ),
        Divider(),
      ],
    );
  }
}



class Exercise {
  String name;
  List<Sets> sets;
  TextEditingController controller;

  Exercise({required this.name, required this.sets})
      : controller = TextEditingController(text: name);
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets.map((set) => set.toJson()).toList(),
    };
  }
}

class Sets {
  int weight;
  int repAmount;
  int RPE;
  TextEditingController weightController;
  TextEditingController repAmountController;
  TextEditingController RPEController;

  Sets({required this.weight, required this.repAmount, required this.RPE})
      : weightController = TextEditingController(text: weight.toString()),
        repAmountController = TextEditingController(text: repAmount.toString()),
        RPEController = TextEditingController(text: RPE.toString());
    Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'repAmount': repAmount,
      'RPE': RPE,
    };
  }
}