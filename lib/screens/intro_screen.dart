import 'package:flutter/material.dart';
import 'package:mindful_app/data/sp_helper.dart';
import 'package:mindful_app/screens/quote_screen.dart';
import 'package:mindful_app/screens/settings_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  String selectedImage = 'Sea';
  String name = '';

  @override
  void initState() {
    super.initState();
    final SPHelper helper = SPHelper();
    helper.getSettings().then((settings) {
      setState(() {
        selectedImage = settings['image'] ?? 'Sea';
        if(settings['image'] == '') {selectedImage = 'Sea';}
        name = settings['name'] ?? '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/$selectedImage.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment(0, -0.75),
            child: Text('Welcome $name', style: TextStyle(color: Colors.white, 
            shadows: [Shadow(blurRadius: 10, color: Colors.black, offset: Offset(5, 5))], fontSize: 24)),
          ),
          Align(
            alignment: Alignment(0, 0.5),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (BuildContext context) => const QuoteScreen())//SettingsScreen()) 
                );
              },
              child: Text('Start'),
            ),
          ),
        ],
      ),
    );
  }
}