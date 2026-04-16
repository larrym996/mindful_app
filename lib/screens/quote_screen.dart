import 'dart:math';

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

  Future<List<String>> search() async {
      const String name = '_ipp._tcp.local'; //'_printer._tcp.local'; // Epson and HP answer to _ipp._tcp.local or _printer._tcp.local

      List<String> uniqueNames = [];

      List<String> retVal = List<String>.empty(growable: true);

    for (int i = 0; i < 5; i++) 
    {
      String message = '';
      MDnsClient client = MDnsClient();
      // Start the client with default options.
      await client.start();

      try { 

      // Get the PTR record for the service.
      await for (final PtrResourceRecord ptr in client
          .lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(name))) {
        // Use the domainName from the PTR record to get the SRV record,
        // which will have the port and local hostname.
        // Note that duplicate messages may come through, especially if any
        // other mDNS queries are running elsewhere on the machine.
        await for (final SrvResourceRecord srv in client.lookup<SrvResourceRecord>(
            ResourceRecordQuery.service(ptr.domainName))) {

          await for (final IPAddressResourceRecord ip in client.lookup<IPAddressResourceRecord>(
              ResourceRecordQuery.addressIPv4(srv.target),) ) {          

              if (!uniqueNames.contains(ptr.domainName)) {
                uniqueNames.add(ptr.domainName);

                message = 'Found Printer: ${ptr.domainName} at ${ip.address.address}:${srv.port}';                                           
              }
          }                           
          client.stop();
          }      
        }
      } catch (e) {
          message = 'Error during mDNS discovery: $e';
      }

      if(message.isNotEmpty) {
        retVal.add(message);
      }        
    }     
    return retVal;
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
          else if(!snapshot.hasData) {
            return const Center(child: Text('No quote available'));
          }
          List<String> messages = snapshot.data as List<String>;
          if(messages.isEmpty) {
            return const Center(child: Text('No printers found'));
          }
          else {
            return ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
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