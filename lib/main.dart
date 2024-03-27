// ignore_for_file: avoid_unnecessary_containers, use_build_context_synchronously, library_private_types_in_public_api

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:nelfox_events/dasboard.dart';
import 'package:nelfox_events/link.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginDemo(),
    );
  }
}

// ignore: use_key_in_widget_constructors
class LoginDemo extends StatefulWidget {
  @override
  _LoginDemoState createState() => _LoginDemoState();
}

class _LoginDemoState extends State<LoginDemo> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Nelfox Car Show"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 110.0),
              child: Center(
                child: SizedBox(
                  height: 100,
                  child: Text(
                    "Nelfox Events",
                    style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: username,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Phone number, email or username',
                    hintText: 'Enter valid email or username'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              child: TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter secure password'),
              ),
            ),
            SizedBox(
              height: 65,
              width: 200,
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 1,
                        enableFeedback: true,
                        backgroundColor: Colors.blue[400]),
                    child: const Text(
                      'Log in ',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () {
                      login(context, username.text, password.text);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void login(BuildContext context, String username, String password) async {
    Links link = Links();
    try {
      final jsonData = {
        "username": username,
        "password": password,
      };
      final query = {"operation": "login", "json": jsonEncode(jsonData)};

      final response =
          await http.get(Uri.parse(link.link).replace(queryParameters: query));

      var result = jsonDecode(response.body);
      if (result == "0") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error"),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Dashboard(
              username: username,
            ),
          ),
        );
      }
    } catch (error) {
      print(error);
    }
  }
}
