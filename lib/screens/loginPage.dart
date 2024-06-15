import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../user_provider.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _login() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();
    

    // Your API endpoint
    final String apiUrl = 'http://192.168.56.1:3000/api/flutterLogin';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        Provider.of<UserProvider>(context, listen: false).setUser(data['body']);
        


        // Handle successful login here
        // Navigate to the next screen or perform any action
        print('Login successful!, user: ${data['body']}');
        Navigator.pushNamed(
          context,
          '/home',
        );
        // Navigate to next screen or do something else
      } else {
        // Handle error response
        setState(() {
          _errorMessage = 'Login failed. Please check your credentials.';
        });
        print('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      // Handle other errors like network issues
      setState(() {
        _errorMessage = 'Error: $e';
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your username';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                if ((_formKey.currentState?.validate() ?? false)) {
                  // If the form is valid, display a Snackbar.
                  _login();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_errorMessage)),
                  );
                  if (!_errorMessage.isNotEmpty){
                    Navigator.pushNamed(
                      context,
                      '/home',
                    );
                  }
                  
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}