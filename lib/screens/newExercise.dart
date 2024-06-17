import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewExerciseScreen extends StatefulWidget {
  const NewExerciseScreen({Key? key}) : super(key: key);
  @override
  _NewExerciseScreenState createState() => _NewExerciseScreenState();
}

class _NewExerciseScreenState extends State<NewExerciseScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _muscleGroupController = TextEditingController();

  Future<void> _submitForm() async {
    String name = _nameController.text;
    String description = _descriptionController.text;
    String muscleGroup = _muscleGroupController.text;

    
    String apiUrl = '${dotenv.env['API_URL']!}/api/createExercise';

    Map<String, dynamic> exerciseData = {
      'name': name,    };

    String jsonBody = json.encode(exerciseData);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        // Success! Handle the response here
        print('Exercise created successfully');
      } else {
        // Error occurred. Handle the error here
        print('Failed to create exercise');
      }
    } catch (e) {
      // Exception occurred. Handle the exception here
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Exercise'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
            TextField(
              controller: _muscleGroupController,
              decoration: InputDecoration(
                labelText: 'Muscle Group',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}