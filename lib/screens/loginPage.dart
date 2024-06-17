import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../user_provider.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';


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
    

    final String? ipAddress = await WifiInfo().getWifiIP();
    print('Device IP Address: $ipAddress');
    
    // Your API endpoint
    final String apiUrl = '${dotenv.env['API_URL']!}/flutterLogin';
    print('API URL: $apiUrl');

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
          '/workouts',
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
      body: Center( // Center the entire form
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
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
                SizedBox(height: 20), // Add some spacing between the fields and the button
                ElevatedButton(
                  onPressed: () {
                    if ((_formKey.currentState?.validate() ?? false)) {
                      _login();
                      if (_errorMessage.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(_errorMessage)),
                        );
                      }
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
