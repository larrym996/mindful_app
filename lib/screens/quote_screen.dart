import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mindful_app/data/db_helper.dart';
import 'dart:convert';
import 'package:mindful_app/data/quote.dart';
import 'package:mindful_app/screens/quotes_list_screen.dart';
import 'package:mindful_app/screens/settings_screen.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  String address = 'https://zenquotes.io/api/random';
  Quote quote = Quote(text: '', author: '');

  @override
  void initState() {
    super.initState();
  }

  Future fetchQuote() async {
      try {
        final Uri url = Uri.parse(address);
        final response = await http.get(url);
        if(response.statusCode != 200) {
          String errorMessage = 'Failed to load quote, response.statusCode=${response.statusCode}';
          return Quote(text: errorMessage, author: '');
        }
        final List data = json.decode(response.body);
        quote = Quote.fromJson(data[0]);
        return quote;
      } on Exception catch (e) {
        return Quote(text: 'Failed to load quote, $e', author: '');
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mindful Quote'),
        actions: [
          IconButton(onPressed: _gotoSettings, icon: const Icon(Icons.settings)),
          IconButton(onPressed: _gotoList, icon: const Icon(Icons.list)),
          IconButton(onPressed: () {fetchQuote(); setState((){} );}, icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder(
        future: fetchQuote(),
        builder: (context, snapshot) {
           if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if(snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          else if(!snapshot.hasData) {
            return const Center(child: Text('No quote available'));
          }
          quote = snapshot.data as Quote;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                quote.text,
                style: const TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
                Text(
                quote.author,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              )],
            ),
          ),
              );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          DBHelper helper = DBHelper();
          helper.insertQuote(quote).then((id) {
            final message = (id == 0) ? 'Failed to save quote.' : 'Quote saved successfully!';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
            );
          });
        },
        child: const Icon(Icons.save),
      ));
  }

  void _gotoSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) => const SettingsScreen()) 
    );
  }
  void _gotoList() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) => const QuotesListScreen()) 
    );
  }
}