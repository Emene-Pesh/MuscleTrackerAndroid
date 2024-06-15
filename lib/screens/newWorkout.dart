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
      exercises[exerciseIndex].sets.add(Set(weight: 0, repAmount: 0, RPE: 0));
    });
  }
  void removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      exercises[exerciseIndex].sets.removeAt(setIndex);
    });
  }

  void updateSet(int exerciseIndex, int setIndex, Set set) {
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
                  return ExerciseInput(
                    exercise: exercises[index],
                    onRemove: () => removeExercise(index),
                    onUpdate: (updatedExercise) => updateExercise(index, updatedExercise),
                    onAddSet: () => addSet(index),
                    onUpdateSet: (setIndex, updatedSet) => updateSet(index, setIndex, updatedSet),
                    onRemoveSet: (setIndex) => removeSet(index, setIndex),
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
  final Function(int, Set) onUpdateSet;
  final Function(int) onRemoveSet;

  ExerciseInput({
    required this.exercise,
    required this.onRemove,
    required this.onUpdate,
    required this.onAddSet,
    required this.onUpdateSet,
    required this.onRemoveSet,
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
            TextField(
              decoration: InputDecoration(labelText: 'Exercise Name'),
              onChanged: (value) {
                exercise.name = value;
                onUpdate(exercise);
              },
              controller: exercise.controller,
            ),
            SizedBox(height: 8.0),
            ListView.builder(
              shrinkWrap: true,
              itemCount: exercise.sets.length,
              itemBuilder: (context, index) {
                return SetInput(
                  set: exercise.sets[index],
                  onUpdate: (updatedSet) => onUpdateSet(index, updatedSet),
                  onRemove: () => onRemoveSet(index),
                );
              },
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
  final Set set;
  final ValueChanged<Set> onUpdate;
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
  List<Set> sets;
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

class Set {
  int weight;
  int repAmount;
  int RPE;
  TextEditingController weightController;
  TextEditingController repAmountController;
  TextEditingController RPEController;

  Set({required this.weight, required this.repAmount, required this.RPE})
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