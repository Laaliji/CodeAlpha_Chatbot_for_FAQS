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
      home: const LandingPage(),
    );
  }
}

// Landing Page
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
              Image.asset('assets/chatbot_image.png', height: 300, width: 300),
              SizedBox(
                height: 100,
                width: 300.0,
                child: Center(
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontFamily: 'MyFont',
                      fontSize: 20,
                      color: Color(0xFF89b3d9),
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          "Hey, I am a ChatBot!",
                          speed: const Duration(milliseconds: 60),
                        ),
                        TypewriterAnimatedText(
                          "How can I help you?",
                          speed: const Duration(milliseconds: 60),
                        ),
                      ],
                      repeatForever: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF7A4B9D)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
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

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  Future<void> sendMessage(String message) async {
    const String apiUrl = 'http://10.0.2.2:5001/';
    if (message.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': message});
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _messages.add({'sender': 'bot', 'text': jsonResponse['response']});
        });
      } else {
        setState(() {
          _messages.add({'sender': 'bot', 'text': "Error: Server responded with status ${response.statusCode}"});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'bot', 'text': "Error: ${e.toString()}"});
      });
    } finally {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE6F1F5),
        ),
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/chatbot_image.png',
                  height: 120,
                  width: 120,
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUserMessage = message['sender'] == 'user';

                  return Align(
                    alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      padding: const EdgeInsets.all(16.0),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isUserMessage ? Color(0xFFadcbed) : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: isUserMessage ? Colors.transparent : Colors.white, width: 2),
                      ),
                      child: Text(
                        message['text']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isUserMessage ? 20 : 12,
                          color: isUserMessage ? Color(0xFFf2f9fb) : Color(0xFF27065e),
                          fontFamily: isUserMessage ? 'Arial' : 'MyFont',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              margin: const EdgeInsets.only(top: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Enter your message',
                  labelStyle: TextStyle(fontSize: 13, color: const Color(0xFF604f8b)),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      sendMessage(_controller.text);
                      _controller.clear();
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
}
