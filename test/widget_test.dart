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
    const url = 'https://your-app-name.vercel.app/api/data'; // Use your deployed URL here
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Directly use the response body as it is a plain string
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

  Future<void> sendComment(String comment) async {
    const url = 'https://your-app-name.vercel.app/api/comment'; // Use your deployed URL here
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'comment': comment,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _response = jsonDecode(response.body)['message'];
        });
      } else {
        setState(() {
          _response = 'Failed to send comment';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    }
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
              child: const Text('Fetch Data'),
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
                  labelText: 'Enter Comment',
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sendComment(_controller.text);
              },
              child: const Text('Send Comment'),
            ),
          ],
        ),
      ),
    );
  }
}
