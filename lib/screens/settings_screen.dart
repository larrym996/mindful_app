import 'package:flutter/material.dart';
import 'package:mindful_app/data/sp_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController txtName = TextEditingController();
  final List<String> _images = ['Sea', 'Lake', 'Mountain', 'Country'];
  String _selectedImage = 'Sea';
  final SPHelper helper = SPHelper();

@override
  void initState() {
    super.initState();
    loadSettings();
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: 
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [TextField(
            controller: txtName,
            decoration: const InputDecoration(
              hintText: 'Enter your name',
              border: OutlineInputBorder(),
            ),
          ),  
          DropdownButton<String>(
            value: _selectedImage,
            items: _images.map((String value) {
              return DropdownMenuItem(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newvalue){
              setState(() {
                _selectedImage = newvalue ?? 'Lake';
              });              
            })        
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        saveSettings().then((value) {
          String message = value ? 'Settings saved successfully' : 'Failed to save settings';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), 
            duration: const Duration(seconds: 3),));
        });
      }, child: const Icon(Icons.save)),
    );
  }

  Future<bool> saveSettings() async {
    return await helper.setSettings(txtName.text, _selectedImage);
  } 

  Future<void> loadSettings() async {

    Map<String, String> settings = await helper.getSettings();
    _selectedImage = settings['image'] ?? 'Sea';
    if(_selectedImage == '') {_selectedImage = 'Sea';}
    txtName.text = settings['name'] ?? '';  
    setState(() {});  
  } 

  @override
  void dispose() {
    txtName.dispose();
    super.dispose();
  }
}