import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:studysama/page/login_Page.dart';
import 'package:studysama/services/firebase_auth_services.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  final FirebaseAuthService _auth = FirebaseAuthService();


  @override
  void dispose() {
    // TODO: implement dispose
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signup () async {
    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    // Perform authentication logic here
    print("Username: $username, Email: $email, Password: $password");

    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    if (user != null) {
      print("User is successfully created");
      Navigator.pushNamed(context, "/home");
    } else {
      print("Error occured");
    }
  }

  void _login() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(flex: 4), // Add some space at the top
              Text(
                "StudySama",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05), // 5% of screen height

              // Username TextField
              TextField(
                controller: _usernameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(FluentSystemIcons.ic_fluent_person_filled),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02), // 2% of screen height

              // Email TextField
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(FluentSystemIcons.ic_fluent_mail_filled),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02), // 2% of screen height

              // Password TextField
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(FluentSystemIcons.ic_fluent_lock_filled),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? FluentSystemIcons.ic_fluent_eye_show_filled : FluentSystemIcons.ic_fluent_eye_hide_filled,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05), // 5% of screen height

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signup,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    child: Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02), // 2% of screen height

              // Back to login TextButton
              TextButton(
                onPressed: _login,
                child: Text(
                  "Already have an account?",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              Spacer(flex: 3), // Add some space at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
