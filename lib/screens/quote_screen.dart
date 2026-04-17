import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mindful_app/data/db_helper.dart';
import 'dart:convert';
import 'package:mindful_app/data/quote.dart';
import 'package:mindful_app/screens/quotes_list_screen.dart';
import 'package:mindful_app/screens/settings_screen.dart';
import 'dart:io';
import 'package:dart_snmp/dart_snmp.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:nsd/nsd.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  String address = 'https://zenquotes.io/api/random';
  Quote quote = Quote(text: '', author: '');

  List<String> seenPrinters = [];

  List<String> printers = List<String>.empty(growable: true);

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

  Future search() async {
      const String name = '_ipp._tcp'; // Epson and HP answer to _ipp._tcp.local or _printer._tcp.local

      final discovery = await startDiscovery(name);
      discovery.addServiceListener((service, status) {
      if (status == ServiceStatus.found) {
        if (!seenPrinters.contains(service.name)) {
          seenPrinters.add(service.name!);
          printers.add('[FOUND] ${service.name}  Host: ${service.host} Port: ${service.port}');
          // if (service.txt != null && service.txt!.isNotEmpty) {
          //   print('  Metadata: ${service.txt}');
          // }
          //print('-----------------------------------------');
        }
      } 
      // else if (status == ServiceStatus.lost) {
      //   print('[LOST]  ${service.name}');
      //   seenPrinters.remove(service.name);
      //   print('-----------------------------------------');
      // }

        // Stop after 60 seconds
        Timer(const Duration(seconds: 60), () async {
          //print('\n[TIMEOUT] Stopping discovery after 60 seconds.');
          await stopDiscovery(discovery);
          //print('Discovery ended. You can close this application.\n');
        });
     });
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mindful Quote'),
        actions: [
          IconButton(onPressed: () {search(); setState((){} );}, icon: const Icon(Icons.search)),
          IconButton(onPressed: _gotoSettings, icon: const Icon(Icons.settings)),
          IconButton(onPressed: _gotoList, icon: const Icon(Icons.list)),
          IconButton(onPressed: () {fetchQuote(); setState((){} );}, icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder(
        future: search(),
        builder: (context, snapshot) {
           if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if(snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // else if(!snapshot.hasData) {
          //   return const Center(child: Text('No quote available'));
          // }
          //List<String> messages = snapshot.data as List<String>;
          if(printers.isEmpty) {
            return const Center(child: Text('Click the magnifying icon to find printers on your local network. It may take up to 60 seconds to find all printers.'));
          }
          else {
            return ListView.builder(
              itemCount: printers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(printers[index]),
                );
              },
            );
          }
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