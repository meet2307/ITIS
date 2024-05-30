// send_reset_link_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:itis_project_python/reset_password_screen.dart';


class SendResetLinkScreen extends StatefulWidget {
  @override
  _SendResetLinkScreenState createState() => _SendResetLinkScreenState();
}

class _SendResetLinkScreenState extends State<SendResetLinkScreen> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> sendResetLink() async {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reset link sent to your email. Please check your inbox.'))
    );
    var response = await http.post(
      Uri.parse('http://localhost:5000/reset_password_request'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': _emailController.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => ResetPasswordTestScreen(email:_emailController.text)),
        //MaterialPageRoute(builder: (context) => Home()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send reset link.'))
      );
    }
  }

  // validate_token() async{
  //   var response = await http.get(Uri.parse('http://localhost:5000/validate_response'));
  //
  //   if (response.statusCode == 200) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Reset password. Type the new one!'))
  //     );
  //     Navigator.of(context).pushReplacement(
  //       MaterialPageRoute(builder: (context) => ResetPasswordTestScreen(email:_emailController.text)),
  //       //MaterialPageRoute(builder: (context) => Home()),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Unauthorized access!'))
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Send Reset Link"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Enter your email'),
            ),
            ElevatedButton(
              onPressed: sendResetLink,
              child: Text('Send Reset Link'),
            ),
          ],
        ),
      ),
    );
  }
}
