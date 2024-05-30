import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:itis_project_python/gradient_button.dart';
import 'package:itis_project_python/login_field.dart';
import 'package:itis_project_python/login_screen.dart';
import 'package:itis_project_python/pallete.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>  {
  final TextEditingController usrName = TextEditingController();
  bool isVisible=false;
  String _role = '';
  final formKey = GlobalKey<FormState>();
  Future<void> resetPassword(BuildContext context) async {
    var response = await http.post(
      Uri.parse('http://localhost:5000/reset_password'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': usrName.text,
      }),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Resest Link sent to email.')));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        //MaterialPageRoute(builder: (context) => Home()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid credentials')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(5.0),
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                // TextField(
                //   controller: _usernameController,
                //   decoration: InputDecoration(labelText: 'Username'),
                // ),
                Image.asset('assets/images/signin_balls.png'),
                const Text(
                  'Reset Password',
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
                    controller: usrName,
                    validator: (value){
                      if(value!.isEmpty){
                        return "Username is required";
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
                      if(_role!.isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Role is not selected. Please choose one.')));
                      }
                      else{
                        resetPassword(context);
                      }
                    },
                    style:
                    ElevatedButton.styleFrom(
                      fixedSize: const Size(395, 55),
                      shadowColor: Colors.transparent,
                    ),
                    child: Text(
                      'Send Link',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}