// reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordTestScreen extends StatefulWidget {
  final String email;
  ResetPasswordTestScreen({required this.email});

  @override
  _ResetPasswordTestScreenState createState() => _ResetPasswordTestScreenState();
}

class _ResetPasswordTestScreenState extends State<ResetPasswordTestScreen> {
  final TextEditingController _passwordController = TextEditingController();

  Future<void> resetPassword() async {
    var response = await http.post(
      Uri.parse('http://localhost:5000/reset_password'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email':widget.email,
        'new_password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Your password has been reset successfully.'))
      );
      Navigator.of(context).pop(); // Optionally pop back to login or another appropriate screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reset password.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reset Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Enter your new password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: resetPassword,
              child: Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
