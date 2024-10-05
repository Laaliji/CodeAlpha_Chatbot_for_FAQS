import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ChatbotPage(),
    );
  }
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  String _response = ""; // Holds the response from the API


  Future<void> testConnection() async {
    const String apiUrl = 'http://localhost:5001/test';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      print("Test response status: ${response.statusCode}");
      print("Test response body: ${response.body}");
    } catch (e) {
      print("Test connection error: $e");
    }
  }

  Future<void> sendMessage(String message) async {
    const String apiUrl = 'http://localhost:5001/';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message}),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _response = jsonResponse['response'];
        });
      } else {
        setState(() {
          _response = "Error: Server responded with status ${response.statusCode}";
        });
      }
    } catch (e) {
      print("Error details: $e");
      setState(() {
        _response = "Error: ${e.toString()}";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Sam'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Enter your message",
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    print("Sending message: ${_controller.text}");
                    sendMessage(_controller.text);
                    _controller.clear();
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _response,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
