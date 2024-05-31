import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:itis_project_python/home_screen.dart';
import 'package:itis_project_python/pallete.dart';
import 'package:itis_project_python/register_screen.dart';
import 'package:itis_project_python/send_reset_link.dart';
import 'package:itis_project_python/session_manager.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isVisible=false;
  String _role = '';
  final formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    var response = await http.post(
      Uri.parse('http://localhost:5000/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': _usernameController.text,
        'password': _passwordController.text,
        'role': _role,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login successful')));
      Navigator.of(context).pushReplacement(
         MaterialPageRoute(builder: (context) => HomeScreen(userRole: _role)),
        //MaterialPageRoute(builder: (context) => Home()),
       );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid credentials')));
    }
  }

  // Assuming you have a method to handle successful login
  void _handleLoginSuccess(String token) {
    SessionManager().setUserToken(token).then((_) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(userRole: 'admin')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(0.0),
        child: Center(
          child: SingleChildScrollView(
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
                        'Sign in.',
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
                        controller: _usernameController,
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
                          hintText: 'Username',
                        ),
                      ),
                    ),
                  // TextField(
                  //   controller: _passwordController,
                  //   obscureText: true,
                  //   decoration: InputDecoration(labelText: 'Password'),
                  // ),
                  const SizedBox(height: 15),
                    ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 400,
                        ),
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _passwordController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
                          obscureText: !isVisible,
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
                            hintText: 'Password',
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    //In here we will create a click to show and hide the password a toggle button
                                    setState(() {
                                      //toggle button
                                      isVisible = !isVisible;
                                    });
                                  },
                                  icon: Icon(isVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off))
                          ),
                        ),
                      ),
                  // ElevatedButton(
                  //   onPressed: _login,
                  //   child: Text('Login'),
                  // ),
                  const SizedBox(height: 15),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Admin'),
                            value: 'admin',
                            groupValue: _role,
                            onChanged: (value) {
                              setState(() {
                                _role = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Student'),
                            value: 'student',
                            groupValue: _role,
                            onChanged: (value) {
                              setState(() {
                                _role = value!;
                              });
                            },
                          ),
                        ),
                      ],
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
                  if(_role.isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Role is not selected. Please choose one.')));
                  }
                  else{
                    _login();
                  }
                },
                style:
                ElevatedButton.styleFrom(
                  fixedSize: const Size(395, 55),
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
              ),
                    ),
                  const SizedBox(height: 15),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                              onPressed: () {
                                //Navigate to sign up
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RegisterScreen()));
                              },
                              child: const Text("SIGN UP"))
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SendResetLinkScreen()),
                          );
                        },
                        child: Text('Forgot Password?'),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
