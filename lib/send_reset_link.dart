// send_reset_link_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:itis_project_python/pallete.dart';
import 'dart:convert';

import 'package:itis_project_python/reset_password_screen.dart';


class SendResetLinkScreen extends StatefulWidget {
  @override
  _SendResetLinkScreenState createState() => _SendResetLinkScreenState();
}

class _SendResetLinkScreenState extends State<SendResetLinkScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool isVisible=false;
  String _role = '';
  final formKey = GlobalKey<FormState>();

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
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset('assets/images/signin_balls.png'),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Get link!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 50,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 400,
                      ),
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _emailController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Email is required';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(27),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Pallete.borderColor,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Pallete.gradient2,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: 'Email',
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Pallete.gradient1,
                            Pallete.gradient2,
                            Pallete.gradient3,
                          ],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          sendResetLink();
                        },
                        style:
                        ElevatedButton.styleFrom(
                          fixedSize: const Size(395, 55),
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          'Send reset link',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
