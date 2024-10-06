import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
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
      debugShowCheckedModeBanner: false,
      title: 'Chatbot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LandingPage(), // Start with the landing page
    );
  }
}

// Landing Page with logo, animated text, and "Get Started" button
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFd0e6f0),


            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo at the center
              Image.asset('assets/chatbot_image.png', height: 300, width: 300),
              // Typing animation for chatbot introduction
              SizedBox(
                height: 100,
                width: 300.0,
                child: Center( // Wrap with Center to align the text
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontFamily: 'MyFont', // Custom font (make sure it's added in pubspec.yaml)
                      fontSize: 20, // Increase font size
                      color: Color(0xFF89b3d9), // Set text color to #04244d

                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          "Hey, I am a ChatBot !",
                          speed: const Duration(milliseconds: 50),
                        ),
                        TypewriterAnimatedText(
                          "How can I help you ?",
                          speed: const Duration(milliseconds: 50),
                        ),
                      ],
                      repeatForever: true, // Loop the animation
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
              // "Get Started" Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  foregroundColor: Colors.white, // Text color
                  side: const BorderSide(color: Color(0xFF7A4B9D)), // Outline color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  // Navigate to the chat page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatbotPage()),
                  );
                },
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 16, color: Color(0xFF7A4B9D), fontFamily: 'MyFont'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Chatbot Page (after pressing "Get Started")
class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  String _response = ""; // Holds the response from the API

  Future<void> sendMessage(String message) async {
    const String apiUrl = 'http://10.0.2.2:5001/';
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
        /*appBar: AppBar(
        title: const Text(
          'Chatbot',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Color(0xFFd0e6f0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),*/
      body: Container(
        decoration: const BoxDecoration(
          color:  Color(0xFFE6F1F5),

        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Enter your message",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    sendMessage(_controller.text);
                    _controller.clear();
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _response,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
