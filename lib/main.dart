// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


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
          ],
        ),
      ),
    );
  }
}
